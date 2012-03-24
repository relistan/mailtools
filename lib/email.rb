
class Email
  attr_accessor :header, :body, :index

  def initialize
  @raw_text = []
    @header = {}
    @body = []
  end

  def self.from_contents(contents)
    email = new
    email.concat contents
    email.parse
    email
  end

  def method_missing method
    return @header[method.to_s] if @header[method.to_s]
	standardized = method.to_s.capitalize.gsub(/_/, '-')
    return @header[standardized] if @header[standardized]
    raise NoMethodError
  end

  def <<(line)
    @raw_text << line
  end

  def concat(contents)
    @raw_text.concat contents
  end

  def empty?
    header.empty? && body.empty?
  end

  def size
    header.size + body.size
  end

  def parse
    return unless body.empty? && header.empty? # Don't keep re-parsing

    state = :header
    @raw_text.each do |line| 
      if blank?(line) && state == :header
          state = :body
        next # Skip first blank line
      end

      case state 
        when :header then header_from_line(line)
        when :body then body << line
      end
    end

    header['Date'] ||= Time.now.gmtime.strftime('%d-%b-%Y %H:%M:%S +0000')
    header['Date'] = Time.parse(header['Date']).strftime('%d-%b-%Y %H:%M:%S +0000')

    return self
  end

  private

    def blank?(line)
      line.empty?
    end

    def header_from_line(line)
      if line =~ /^([^ ]+?):(.+)$/
        key   = $1 || ''
        value = $2 || ''
        @header[key.capitalize] = value.strip
      end
    end
end
