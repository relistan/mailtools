#!/usr/bin/env ruby

require 'net/imap'
require 'optparse'
require 'mbox'
require 'pp'

$options = {}

def parse_opts
	opts = OptionParser.new do |opts|
	
		opts.banner = "Usage: mbox2imap.rb [options]"
	
		opts.on("-f FILENAME", "--filename FILENAME", String, "Filename of the local UNIX mbox") do |filename|
			$options[:filename] = filename
		end
	
		opts.on("-h HOSTNAME[:PORT]", "--hostname HOSTNAME[:PORT]", String, 
			"Hostname of IMAP server") do |hostname|
			if hostname =~ /\A(.*?):(.*)\Z/
				$options[:hostname] = $1
				$options[:port] = $2
			else
				$options[:hostname] = hostname
			end
		end
	
		opts.on("-p PASSWORD", "--password PASSWORD", String, "IMAP password") do |pass|
			$options[:password] = pass
		end
	
		opts.on("-u USERNAME", "--username USERNAME", String, "IMAP username") do |uname|
			$options[:username] = uname
		end

		opts.on("-m FOLDER", "--folder FOLDER", String, "IMAP folder") do |folder|
			$options[:folder] = folder
		end

		opts.on("-s", "--ssl", "IMAP server uses SSL") do
			$options[:ssl] = true
		end

		opts.on("-r", "--mark-read", "Mark uploaded messages as read") do |markread|
			$options[:markread] = true
		end
	
	end
	
	opts.parse!(ARGV)
	
	# All are required $options
	[:filename, :hostname, :password, :username].each do |option|
		if !$options.has_key? option
			puts "#{option} is required"
			puts opts
			exit
		end
	end

	$options[:folder]	||= 'INBOX'
	$options[:ssl]		||= false
	$options[:port]		||= 143
	$options[:markread]	||= false
end

parse_opts

mbox = Mbox.new($options[:filename])
mbox.parse

imap = Net::IMAP.new(
	$options[:hostname], 
	$options[:port],
	$options[:ssl]
)
imap.login(
	$options[:username], 
	$options[:password]
)
imap.select($options[:folder])

flags = $options[:markread] ? [:Seen] : []
failed = []
puts "Beginning upload of #{(mbox.size) - 1} messages from #{$options[:filename]}"
mbox.each_with_index do |msg,i|
	msg.parse
	puts "#{sprintf('%04d', i)} #{sprintf('%50s', msg.Subject)} | #{msg.Date}"
	tried = 0
	begin
		tried += 1
		imap.append($options[:folder], msg.join(''), 
			flags,
			msg.Date
		)
	rescue Net::IMAP::NoResponseError => e
		if tried < 10
			puts "Error: #{e.message} trying again."
			sleep 1
			retry
		else
			puts "Error: #{e.message} max retries hit.  Skipping."
			failed << msg
		end
	end
end

puts "-" * 80
puts Time.now
print "Total: #{(mbox.size) - 1}"
if failed.size > 0
	puts " failed: #{(failed.size) - 1}"
	failed.each { |m| puts "fail #{sprintf("%04d", m.index)} #{m.Subject}" }
	puts "-" * 80
end
puts
puts "-" * 80
