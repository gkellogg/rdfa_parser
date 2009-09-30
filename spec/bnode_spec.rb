require File.join(File.dirname(__FILE__), 'spec_helper')
describe "Blank nodes" do
  it "should accept a custom identifier" do
    b = BNode.new('foo')
    b.identifier.should == "foo"
    b.to_s.should == "foo"
  end
  
  it "should reject custom identifiers if they are not acceptable" do
    b = BNode.new("4cake")
    b.identifier.should_not == "4cake"
  end
  
  it "should be expressible in NT syntax" do
    b = BNode.new('test')
    b.to_ntriples.should == "_:test"
  end
  
  it "should be able to determine equality" do
    a = BNode.new('a')
    a2 = BNode.new('a')
    a.eql?(a2).should be_true
    
    a3 = URIRef.new('http://somehost.com/wherever.xml')
    a.eql?(a3).should be_false
  end
  
end
