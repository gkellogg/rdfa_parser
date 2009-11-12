require File.join(File.dirname(__FILE__), 'spec_helper')

require 'rdfa_helper'

# Time to add your specs!
# http://rspec.info/
describe "RDFa parser" do
  it "should parse simple doc" do
    sampledoc = <<-EOF;
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:dc="http://purl.org/dc/elements/1.1/">
    <head>
    	<title>Test 0001</title>
    </head>
    <body>
    	<p>This photo was taken by <span class="author" about="photo1.jpg" property="dc:creator">Mark Birbeck</span>.</p>
    </body>
    </html>
    EOF

    parser = RdfaParser::RdfaParser.new
    parser.parse(sampledoc, "http://rdfa.digitalbazaar.com/test-suite/test-cases/xhtml1/0001.xhtml")
    parser.graph.size.should == 1
    
    parser.graph.to_rdfxml.should be_valid_xml
  end

  it "should parse XML Literal and generate valid XML" do
    sampledoc = <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:dc="http://purl.org/dc/elements/1.1/">
    	<head>
    		<title>Test 0011</title>
    	</head>
      <body>
      	<div about="">
          Author: <span property="dc:creator">Albert Einstein</span>
          <h2 property="dc:title">E = mc<sup>2</sup>: The Most Urgent Problem of Our Time</h2>
    	</div>
      </body>
    </html>
    EOF

    parser = RdfaParser::RdfaParser.new
    parser.parse(sampledoc, "http://rdfa.digitalbazaar.com/test-suite/test-cases/xhtml1/0011.xhtml")
    parser.graph.size.should == 2
    
    xml = parser.graph.to_rdfxml
    xml.should be_valid_xml
    
    # Ensure that enclosed literal is also valid
    xml.should include("E = mc<sup xmlns=\"http://www.w3.org/1999/xhtml\">2</sup>: The Most Urgent Problem of Our Time")
  end


  it "should parse BNodes" do
    sampledoc = <<-EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML+RDFa 1.0//EN" "http://www.w3.org/MarkUp/DTD/xhtml-rdfa-1.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"
          xmlns:foaf="http://xmlns.com/foaf/0.1/">
      <head>
    	<title>Test 0017</title>   
      </head>
      <body>
      	 <p>
              <span about="[_:a]" property="foaf:name">Manu Sporny</span>
               <span about="[_:a]" rel="foaf:knows"
    resource="[_:b]">knows</span>
               <span about="[_:b]" property="foaf:name">Ralph Swick</span>.
            </p>
      </body>
    </html>
    EOF

    parser = RdfaParser::RdfaParser.new
    parser.parse(sampledoc, "http://rdfa.digitalbazaar.com/test-suite/test-cases/xhtml1/0011.xhtml")
    parser.graph.size.should == 3
    
    xml = parser.graph.to_rdfxml
    xml.should be_valid_xml
    
    xml.should include("Ralph Swick")
    xml.should include("Manu Sporny")
  end
  
  def self.test_cases(suite)
    RdfaHelper::TestCase.test_cases(suite)
  end

  # W3C Test suite from http://www.w3.org/2006/07/SWD/RDFa/testsuite/
  %w(xhtml).each do |suite|
    describe "w3c #{suite} testcases" do
      describe "that are approved" do
        test_cases(suite).each do |t|
          next unless t.status == "approved"
          #next unless t.name =~ /0131/
          #puts t.inspect
          specify "test #{t.name}: #{t.title}#{",  (negative test)" unless t.expectedResults}" do
            begin
              t.run_test do |rdfa_string, rdfa_parser|
                rdfa_parser.parse(rdfa_string, t.informationResourceInput)
              end
            rescue Spec::Expectations::ExpectationNotMetError => e
              if t.title =~ /XML/
                pending("XML Tests known to not work propery with Rasqal") {  raise }
              else
                raise
              end
            end
          end
        end
      end
      describe "that are unreviewed" do
        test_cases(suite).each do |t|
          next unless t.status == "unreviewed"
          #next unless t.name =~ /0092/
          #puts t.inspect
          specify "test #{t.name}: #{t.title}#{",  (negative test)" unless t.expectedResults}" do
            begin
              t.run_test do |rdfa_string, rdfa_parser|
                rdfa_parser.parse(rdfa_string, t.informationResourceInput)
              end
            rescue Spec::Expectations::ExpectationNotMetError => e
              pending() {  raise }
            end
          end
        end
      end
    end
  end
end