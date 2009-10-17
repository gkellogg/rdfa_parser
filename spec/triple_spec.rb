require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Triples" do
  it "should require that the subject is a URIRef or BNode" do
   lambda do
     Triple.new(Literal.new("foo"), URIRef.new("http://xmlns.com/foaf/0.1/knows"), BNode.new)
    end.should raise_error
  end

  it "should require that the predicate is a URIRef" do
    lambda do
      Triple.new(BNode.new, BNode.new, BNode.new)
    end.should raise_error
  end

  it "should require that the object is a URIRef, BNode, Literal or Typed Literal" do
    lambda do
      Triple.new(BNode.new, URIRef.new("http://xmlns.com/foaf/0.1/knows"), [])
    end.should raise_error
  end

  describe "with BNodes" do
    subject { Triple.new(BNode.new, URIRef.new('http://xmlns.com/foaf/0.1/knows'), BNode.new) }

    it "should have a subject" do
      subject.subject.class.should == BNode
    end
    
    it "should emit an NTriple" do
      subject.to_ntriples.should == "#{subject.subject.to_n3} <http://xmlns.com/foaf/0.1/knows> #{subject.object.to_n3} ."
    end
  end

  describe "with URIRefs" do
    subject {
      s = URIRef.new("http://tommorris.org/foaf#me")
      p = URIRef.new("http://xmlns.com/foaf/0.1/name")
      o = Literal.untyped("Tom Morris")
      Triple.new(s,p,o)
    }

    it "should emit an NTriple" do
      subject.to_ntriples.should == "<http://tommorris.org/foaf#me> <http://xmlns.com/foaf/0.1/name> \"Tom Morris\" ."
    end
  end

  describe "with coerced subject" do
    it "should accept a URIRef" do
      ref = URIRef.new('http://localhost/')
      Triple.coerce_subject(ref).should == ref
    end

    it "should accept a BNode" do
      node = BNode.new('a')
      Triple.coerce_subject(node).should == node
    end

    it "should accept a uri string and make URIRef" do
      Triple.coerce_subject('http://localhost/').should == URIRef.new('http://localhost/')
    end
    
    it "should accept an Addressable::URI object and make URIRef" do
      Triple.coerce_subject(Addressable::URI.parse("http://localhost/")).should == URIRef.new("http://localhost/")
    end
    
    it "should turn an other string into a BNode" do
      Triple.coerce_subject('foo').should == BNode.new('foo')
    end

    it "should raise an InvalidSubject exception with any other class argument" do
      lambda do
        Triple.coerce_subject(Object.new)
      end.should raise_error(Triple::InvalidSubject)
    end
  end

  describe "with coerced predicate" do
    it "should make a string into a URI ref" do
      Triple.coerce_predicate("http://localhost/").should == URIRef.new('http://localhost/')
    end

    it "should leave a URIRef alone" do
      ref = URIRef.new('http://localhost/')
      Triple.coerce_predicate(ref).should == ref
    end

    it "should barf on an illegal uri string" do
      lambda do
        Triple.coerce_predicate("I'm just a soul whose intention is good")
      end.should raise_error(Triple::InvalidPredicate)
    end
  end

  describe "with coerced object" do
    it "should leave URIRefs alone" do
      ref = URIRef.new("http://localhost/")
      Triple.coerce_object(ref).should == ref
    end
    
    it "should accept an Addressable::URI object and make URIRef" do
      Triple.coerce_object(Addressable::URI.parse("http://localhost/")).should == URIRef.new("http://localhost/")
    end
    
    it "should leave BNodes alone" do
      ref = BNode.new()
      Triple.coerce_object(ref).should == ref
    end
    
    it "should leave Literals alone" do
      ref = Literal.untyped('foo')
      Triple.coerce_object(ref).should == ref
      
      typedref = Literal.build_from('foo')
      Triple.coerce_object(ref).should == ref
    end
    
  end
  
  describe "equivalence" do
    before(:all) do
      @test_cases = [
        Triple.new(URIRef.new("http://foo"),URIRef.new("http://bar"),URIRef.new("http://baz")),
        Triple.new(URIRef.new("http://foo"),URIRef.new("http://bar"),Literal.untyped("baz")),
        Triple.new(URIRef.new("http://foo"),"http://bar",Literal.untyped("baz")),
        Triple.new(BNode.new("foo"),URIRef.new("http://bar"),Literal.untyped("baz")),
        Triple.new(BNode.new,URIRef.new("http://bar"),Literal.untyped("baz")),
      ]
    end
    it "should be equal to itself" do
      @test_cases.each {|triple| triple.should == triple}
    end

    it "should not be equal to something else" do
      t = Triple.new(URIRef.new("http://fab"),URIRef.new("http://bar"),URIRef.new("http://baz")),
      @test_cases.each {|triple| triple.should_not == t}
    end

    it "should be equal to equivalent" do
      @test_cases.each do |triple|
        t = Triple.new(triple.subject.to_s, triple.predicate.to_s, triple.object)
        triple.should == t
      end
    end
  end
end
