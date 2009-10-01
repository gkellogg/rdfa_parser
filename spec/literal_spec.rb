require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Literals" do
  it "accept a language tag" do
    f = Literal.untyped("tom", "en")
    f.lang.should == "en"
  end
  
  it "accepts an encoding" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.encoding.to_s.should == "http://www.w3.org/2001/XMLSchema#string"
  end
  
  it "should be equal if they have the same contents" do
    f = Literal.untyped("tom")
    g = Literal.untyped("tom")
    f.should == g    
  end
  
  it "should not be equal if they do not have the same contents" do
    f = Literal.untyped("tom")
    g = Literal.untyped("tim")
    f.should_not == g
  end
  
  it "should be equal if they have the same contents and language" do
    f = Literal.untyped("tom", "en")
    g = Literal.untyped("tom", "en")
    f.should == g
  end

  it "should return a string using to_s" do
    f = Literal.untyped("tom")
    f.to_s.should == "tom"
  end
  
  it "should not be equal if they do not have the same contents and language" do
    f = Literal.untyped("tom", "en")
    g = Literal.untyped("tim", "en")
    f.should_not == g
    
    lf = Literal.untyped("tom", "en")
    lg = Literal.untyped("tom", "fr")
    lf.should_not == lg
  end
  
  it "should be equal if they have the same contents and datatype" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    f.should == g
  end

  it "should not be equal if they do not have the same contents and datatype" do
    f = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g = Literal.typed("tim", "http://www.w3.org/2001/XMLSchema#string")
    f.should_not == g

    dtf = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    dtg = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#token")
    dtf.should_not == dtg
  end
  
  describe "valid N3/NTriples format strings" do
    it "should return quoted string" do
      f = Literal.untyped("tom")
      f.to_n3.should == "\"tom\""
      f.to_ntriples.should == f.to_n3
    end
    
    it "should return quoted string with language" do
      g = Literal.untyped("tom", "en")
      g.to_n3.should == "\"tom\"@en"
      g.to_ntriples.should == g.to_n3
    end
    
    it "should quote integer" do
      typed_int = Literal.typed(5, "http://www.w3.org/2001/XMLSchema#int")
      typed_int.to_n3.should == "\"5\"^^<http://www.w3.org/2001/XMLSchema#int>"
      typed_int.to_ntriples.should == typed_int.to_n3
    end
    
    it "should indicate typed string" do
      typed_string = Literal.typed("foo", "http://www.w3.org/2001/XMLSchema#string")
      typed_string.to_n3.should == "\"foo\"^^<http://www.w3.org/2001/XMLSchema#string>"
    end
    
    it "should escape extended characters" do
      g = Literal.untyped("松本 后子")
      g.to_n3.should == "\"\\\u677E\\\u672C \\\u540E\\\u5B50\""
    end
  end
  
  it "should normalize language tags to lower case" do
    f = Literal.untyped("tom", "EN")
    f.lang.should == "en"
  end
  
  it "should support TriX encoding" do
    e = Literal.untyped("tom")
    e.to_trix.should == "<plainLiteral>tom</plainLiteral>"
    
    f = Literal.untyped("tom", "en")
    f.to_trix.should == "<plainLiteral xml:lang=\"en\">tom</plainLiteral>"
    
    g = Literal.typed("tom", "http://www.w3.org/2001/XMLSchema#string")
    g.to_trix.should == "<typedLiteral datatype=\"http://www.w3.org/2001/XMLSchema#string\">tom</typedLiteral>"
  end
  
  describe "XML Literals" do
    it "should indicate xmlliteral?" do
      f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      f.xmlliteral?.should == true
    end
    
    it "should properly encode non-namespace literal" do
      f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      f.to_n3.should == "\"foo <sup>bar</sup> baz!\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>"
      f.to_ntriples.should == f.to_n3
    end
    
    it "should add single namespace" do
      f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral",
        :namespaces => {"dc" => Namespace.new("http://purl.org/dc/elements/1.1/", "dc")})
        f.to_n3.should == "\"foo <sup xmlns:dc=\\\"http://purl.org/dc/elements/1.1/\\\">bar</sup> baz!\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>"
        f.to_ntriples.should == f.to_n3
    end
    
    it "should add default namespace" do
      f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral",
        :namespaces => {"" => Namespace.new("http://purl.org/dc/elements/1.1/", "")})
      f.to_n3.should == "\"foo <sup xmlns=\\\"http://purl.org/dc/elements/1.1/\\\">bar</sup> baz!\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>"
      f.to_ntriples.should == f.to_n3
    end
    
    it "should compare literals" do
      f = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      g = Literal.typed("foo <sup>bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      f.should == g
    end

    it "should ignore namespace order" do
      f = Literal.typed("foo <sup <sup xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\">bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      g = Literal.typed("foo <sup <sup xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\">bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      f.should == g
    end
    
    it "should ignore attribute order" do
      f = Literal.typed("foo <sup a=\"a\" b=\"b\">bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      g = Literal.typed("foo <sup b=\"b\" a=\"a\">bar</sup> baz!", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
      f.should == g
    end
  end

  it "build_from should infer the type" do
    int = Literal.build_from(15)
    int.encoding.should == "http://www.w3.org/2001/XMLSchema#int"
    
    float = Literal.build_from(15.4)
    float.encoding.should == "http://www.w3.org/2001/XMLSchema#float"
    
    other = Literal.build_from("foo")
    other.encoding.should == "http://www.w3.org/2001/XMLSchema#string"
  end
  
  it "should support XML Literals" do
    xml = Literal.typed("<b>foo</b>", "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral")
    xml.encoding.should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral"
    xml.to_n3.should == "\"<b>foo</b>\"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral>"
  end
  
#  it "build_from_language" do
#    english = Literal.build_from_language("Have a nice day")
#    english.encoding.should == "en"
#    
#    french = Literal.build_from_language("Bonjour, madame. Parlez vous francais?")
#    french.encoding.should == "fr"
#    
#    german = Literal.build_from_language("Achtung")
#    german.encoding.should == "de"
#  end

  # TODO: refactor based on new interface
  # describe "Languages" do
  #   it "should be inspectable" do
  #     literal = Reddy::Literal.new("foo", "en")
  #     lang = literal.lang
  #     lang.to_s == "en"
  #     lang.hash.class.should == Fixnum
  #   end    
  # end
  
end
