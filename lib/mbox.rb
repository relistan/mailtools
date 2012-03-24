$: << File.expand_path(File.dirname(__FILE__))
require 'time'
require 'forwardable'
require 'email'

class Mbox
  include Enumerable
  extend  Forwardable

  def_delegators :@messages, :each, :size, :empty?, :[]

  def initialize filename
    @messages = []
    @filename = File.expand_path(filename)
    if !File.exist? @filename
      raise IOError, "Can't find #{@filename}"
    end
    parse
  end

  def index_array
    @messages.map do |message|
      "#{sprintf("%04d", message.index)}: #{sprintf("%-50s", message.Subject)} | #{message.Date}"
    end
  end

  def index
    puts index_array.join("\n")
  end

  private
    def new_message_line?(line)
      !!(line =~ /\AFrom .*\d{4}/)
    end

    def blank?(line)
      !!(line =~ /\A\Z/o)
    end

    def parse 
    email_data = []
      File.open(@filename, "r").each_line do |line|
        next if blank?(line) && @messages.empty?

        if new_message_line?(line) && !email_data.empty?
  	      message = Email.from_contents(email_data)
          message.index = @messages.size
          @messages << message unless message.empty?
  	      email_data = []
        else
            email_data << line
        end
      end

      # Store the last message
      @messages << Email.from_contents(email_data) unless email_data.empty?
    end
end
