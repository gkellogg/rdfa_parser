require 'net/http'

module RdfaParser
  class URIRef
    attr_accessor :uri
    def initialize (*args)
      args.each {|s| test_string(s)}
      if args.size == 1
        @uri = Addressable::URI.parse(args[0].to_s)
      else
        @uri = Addressable::URI.join(*args.map{|s| s.to_s}.reverse)
      end
      if @uri.relative?
        raise UriRelativeException, "<" + @uri.to_s + ">"
      end
      if !@uri.to_s.match(/^javascript/).nil?
        raise "Javascript pseudo-URIs are not acceptable"
      end
    end
    
    def + (input)
      if input.class == String
        input_uri = Addressable::URI.parse(input)
      else
        input_uri = Addressable::URI.parse(input.to_s)
      end
      return URIRef.new(input_uri, self.to_s)
    end
    
    def short_name
      if @uri.fragment()
        return @uri.fragment()
      elsif @uri.path.split("/").last.class == String and @uri.path.split("/").last.length > 0
        return @uri.path.split("/").last
      else
        return false
      end
    end
  
    def == (other)
      case other
      when URIRef   then @uri == other.uri
      else               @uri.to_s == other
      end
    end
  
    def to_s
      @uri.to_s
    end
  
    def to_ntriples
      "<" + @uri.to_s + ">"
    end
  
    def test_string (string)
      string.to_s.each_byte do |b|
        if b >= 0 and b <= 31
          raise "URI must not contain control characters"
        end
      end
    end
  end
end
