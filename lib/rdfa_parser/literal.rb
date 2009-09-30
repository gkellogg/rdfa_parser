require 'iconv'

module RdfaParser
    # An RDF Literal, with value, type and language elements.
    class Literal
      attr :value
      attr :type
      attr :lang

      alias_method :encoding, :type
      
      # Create a new Literal. Optinally pass a namespaces hash
      # for use in applying to rdf::XMLLiteral values.
      def initialize(value, type, lang, options = {})
        @value = value
        @type = type
        raise "type not URIRef" unless type.nil? || type.is_a?(URIRef)
        @lang = lang
        options = {:namespaces => {}}.merge(options)

        if type == XML_LITERAL
          # Map namespaces from context to each top-level element found within snippet
          value = Nokogiri::XML::Document.parse("<foo>#{value}</foo>").root if value.is_a?(String)
          @value = value.children.map do |c|
            if c.is_a?(Nokogiri::XML::Element)
              options[:namespaces].values.each do |ns|
                c[ns.xmlns_attr] = ns.uri.to_s
                #puts ns.inspect
              end
            end
            c.to_s
          end.join("")
        end
      end
      
      def self.untyped(contents, language = nil)
        new(contents, nil, language)
      end
      
      def self.typed(contents, type)
        type = URIRef.new(type) unless type.is_a?(URIRef)
        new(contents, type, nil)
      end
      
      def self.build_from(object)
        new(object.to_s, infer_encoding_for(object), nil)
      end

      def self.infer_encoding_for(object)
        case object
        when Integer  then URIRef.new("http://www.w3.org/2001/XMLSchema#int")
        when Float    then URIRef.new("http://www.w3.org/2001/XMLSchema#float")
        else               URIRef.new("http://www.w3.org/2001/XMLSchema#string")
        end
      end

      # Serialize literal, adding datatype and language elements, if present.
      # XMLLiteral and String values are encoding using C-style strings with
      # non-printable ASCII characters escaped.
      def to_ntriples
        # Perform translation on value if it's typed
        v = case type
        when XML_LITERAL  then "\"#{to_c_style}\""
        when URIRef       then "\"#{value.to_s}\""
        else                   "\"#{to_c_style}\""
        end

        v + (type ? "^^#{type.to_ntriples}" : "") + (lang ? "@#{lang}" : "")
      end
      alias_method :to_n3, :to_ntriples

      # Output value
      def to_s
        @value.to_s
      end

      def ==(other)
        case other
        when String     then other == self.value
        when self.class
#          puts "Lit== #{other.lang.class} #{self.lang.class} #{other.lang == self.lang}"
          if self.type == XML_LITERAL && other.type == XML_LITERAL
            # XML compare of values
            # FIXME: Nokogiri doesn't do a deep compare of elements
           other.value == self.value && other.lang.to_s == self.lang.to_s
           true
          else
            other.value == self.value &&
            other.type.to_s == self.type.to_s &&
            other.lang.to_s == self.lang.to_s
          end
        else false
        end
      end
      
      # "Borrowed" from JSON utf8_to_json
      MAP = {
        "\x0" => '\u0000',
        "\x1" => '\u0001',
        "\x2" => '\u0002',
        "\x3" => '\u0003',
        "\x4" => '\u0004',
        "\x5" => '\u0005',
        "\x6" => '\u0006',
        "\x7" => '\u0007',
        "\b"  =>  '\b',
        "\t"  =>  '\t',
        "\n"  =>  '\n',
        "\xb" => '\u000B',
        "\f"  =>  '\f',
        "\r"  =>  '\r',
        "\xe" => '\u000E',
        "\xf" => '\u000F',
        "\x10" => '\u0010',
        "\x11" => '\u0011',
        "\x12" => '\u0012',
        "\x13" => '\u0013',
        "\x14" => '\u0014',
        "\x15" => '\u0015',
        "\x16" => '\u0016',
        "\x17" => '\u0017',
        "\x18" => '\u0018',
        "\x19" => '\u0019',
        "\x1a" => '\u001A',
        "\x1b" => '\u001B',
        "\x1c" => '\u001C',
        "\x1d" => '\u001D',
        "\x1e" => '\u001E',
        "\x1f" => '\u001F',
        '"'   =>  '\"',
        '\\'  =>  '\\\\',
        '/'   =>  '/',
      } # :nodoc:

      # Convert a UTF8 encoded Ruby string _string_ to a C-style string, encoded with
      # UTF16 big endian characters as \U????, and return it.
      if String.method_defined?(:force_encoding)
        def to_c_style # :nodoc:
          string = value.dup
          string << '' # XXX workaround: avoid buffer sharing
          string.force_encoding(Encoding::ASCII_8BIT)
          string.gsub!(/["\\\/\x0-\x1f]/) { MAP[$&] }
          string.gsub!(/(
                          (?:
                            [\xc2-\xdf][\x80-\xbf]    |
                            [\xe0-\xef][\x80-\xbf]{2} |
                            [\xf0-\xf4][\x80-\xbf]{3}
                          )+ |
                          [\x80-\xc1\xf5-\xff]       # invalid
                        )/nx) { |c|
                          c.size == 1 and raise GeneratorError, "invalid utf8 byte: '#{c}'"
                          s = Iconv.new('utf-16be', 'utf-8').iconv(c).unpack('H*')[0].upcase
                          s.gsub!(/.{4}/n, '\\\\u\&')
                        }
          string.force_encoding(Encoding::UTF_8)
          string
        end
      else
        def to_c_style # :nodoc:
          string = value.gsub(/["\\\/\x0-\x1f]/) { MAP[$&] }
          string.gsub!(/(
                          (?:
                            [\xc2-\xdf][\x80-\xbf]    |
                            [\xe0-\xef][\x80-\xbf]{2} |
                            [\xf0-\xf4][\x80-\xbf]{3}
                          )+ |
                          [\x80-\xc1\xf5-\xff]       # invalid
                        )/nx) { |c|
                          c.size == 1 and raise GeneratorError, "invalid utf8 byte: '#{c}'"
                          s = Iconv.new('utf-16be', 'utf-8').iconv(c).unpack('H*')[0].upcase
                          s.gsub!(/.{4}/n, '\\\\u\&')
                        }
          string
       end
      end
    end
end
