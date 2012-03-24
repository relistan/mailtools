#!/usr/bin/env ruby

require 'time'
require 'optparse'

if File.exist? 'mbox.rb'
  require 'mbox'
elsif File.exist? File.join(File.expand_path(File.dirname(__FILE__)), 'mbox.rb')
  require File.join(File.expand_path(File.dirname(__FILE__)), 'mbox.rb')
else
  STDERR.puts "Can't find mbox.rb that shipped with mailtools."
  exit
end

$options = {}

def parse_opts
  opts = OptionParser.new do |opts|

    opts.banner = "Usage: maildir2mbox.rb [options]\n\t"
    opts.banner += "Generates an unsorted mbox from a maildir"
  
    opts.on("-d DIRECTORY", "--dir DIRECTORY", String, "The directory containing the mail files") do |dir|
      $options[:dir] = dir
    end
  
    opts.on("-f FILENAME", "--filename FILENAME", String, "Output filename") do |filename|
      $options[:filename] = filename
    end
  
    opts.on("-r", "--recursive", "Recursively handle directories") do
      $options[:recursive] = true
    end
  
    opts.parse!(ARGV)
  
    [:dir, :filename].each do |option|
      if !$options.has_key? option
        puts "#{option} is required"
        puts opts
        exit
      end
    end
  end
end

parse_opts

outfile = File.open(File.expand_path($options[:filename]), 'w')
basedir = Dir.new(File.expand_path($options[:dir]))

dirs = []
dirs << basedir
dirs.each do |dir|
  puts "Adding content from #{dir.path}"
  dir.each do |file|
    next if ((file == '.') || (file == '..'))
  
    if File.ftype(File.join(dir.path, file)) == 'directory'
      dirs << Dir.new(File.join(dir.path, file)) if $options[:recursive]
      next
    end
    puts "  - #{file}"

    file = File.join(dir.path, file)
  
    mail = Email.new File.open(file, "r").readlines
    next if mail.size < 1
  
    mail.parse
    from = mail.From ? mail.From : 'unknown@example.com'
  
    outfile.puts "\nFrom <#{from}> #{mail.Date}\n#{mail.join('')}"
  end
end

outfile.close
