#!/usr/bin/env ruby

$: << File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailtools/mbox'

if ARGV.size > 1
  mbox = Mailtools::Mbox.new ARGV[0]
  mail = mbox[ARGV[1].to_i]
  puts
  puts "From:  #{mail.From}"
  puts "To:  #{mail.To}"
  puts "Date:  #{mail.Date}"
  puts "Subject: #{mail.Subject}"
  puts
  puts mail.body
elsif ARGV.size == 1
  mbox = Mailtools::Mbox.new ARGV[0]
  mbox.index
  puts "TOTAL: #{mbox.size}"
else
  puts "Usage: mboxreader.rb mboxfilename [msg_index]"
end
