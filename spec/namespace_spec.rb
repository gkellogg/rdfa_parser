require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Namespace" do
  it "should use method_missing to create URIRefs on the fly" do
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    foaf.knows.to_s.should == "http://xmlns.com/foaf/0.1/knows"
    
    foaf_frag = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf", true)
    foaf_frag.knows.to_s.should == "http://xmlns.com/foaf/0.1/#knows"
  end
  
  it "should have a URI" do
    lambda do
      test = Namespace.new(short='foaf')
    end.should raise_error
  end
  
  it "should have equality with URIRefs" do
      foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
      foaf_name = URIRef.new("http://xmlns.com/foaf/0.1/name")
      foaf.name.should == foaf_name
  end
  
  it "should have an XML and N3-friendly prefix" do
    lambda do
      test = Namespace.new('http://xmlns.com/foaf/0.1/', '*~{')
    end.should raise_error
  end
  
  it "should be able to attach to the graph for substitution" do
    # rdflib does this using graph.bind('prefix', namespace)
    g = Graph.new
    foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
    foaf.bind(g)
    g.nsbinding["foaf"].should == foaf
  end
  
  it "should not allow you to attach to non-graphs" do
    lambda do
      foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf")
      foaf.bind("cheese")
    end.should raise_error
  end
  
  describe "URI construction" do
    before(:all) { @foaf = Namespace.new("http://xmlns.com/foaf/0.1/", "foaf") }
    it "should construct URI" do
      @foaf.foo.class.should == URIRef
      @foaf.foo.should == "http://xmlns.com/foaf/0.1/foo"
    end
    
    it "should construct URI with +" do
      (@foaf + "foo").class.should == URIRef
      (@foaf + "foo").should == "http://xmlns.com/foaf/0.1/foo"
    end
    
    it "will cause method conflict" do
      (@foaf + "class").should == "http://xmlns.com/foaf/0.1/class"
      @foaf.class.should ==  Namespace
    end
  end
end
