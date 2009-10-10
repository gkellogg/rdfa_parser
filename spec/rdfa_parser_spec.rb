require File.join(File.dirname(__FILE__), 'spec_helper')

require 'rdfa_helper'

# Time to add your specs!
# http://rspec.info/
describe "RDFa parser" do
  it "should be able to pass xhtml1-0001.xhtml" do
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
    parser.parse(sampledoc, "http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/0001.xhtml")
    parser.graph.size.should == 1
  end

  # W3C Test suite from http://www.w3.org/2006/07/SWD/RDFa/testsuite/
  describe "w3c xhtml1 testcases" do
    def self.test_cases
      RdfaHelper::TestCase.test_cases
    end

    test_cases.each do |t|
      #next unless t.name == "Test0101"
      specify "test #{t.name}: #{t.title}" do
        rdfa_string = File.read(t.informationResourceInput)
        rdfa_parser = RdfaParser::RdfaParser.new
        rdfa_parser.parse(rdfa_string, t.originalInformationResourceInput)

        query_string = t.informationResourceResults ? File.read(t.informationResourceResults) : ""

        if query_string.match(/UNION/)
          # Check triples, as Rasql doesn't implement UNION
          ntriples = File.read(t.informationResourceResults.sub("sparql", "nt"))
          parser = NTriplesParser.new(ntriples)
          rdfa_parser.graph.should be_equivalent_graph(parser.graph, t.information)
        else
          rdfa_parser.graph.should pass_query(query_string, t.information)
        end
      end
    end
  end
end