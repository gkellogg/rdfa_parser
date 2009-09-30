require 'rdf/redland'

module RdfaHelper
  # Class representing test cases in format http://www.w3.org/2006/03/test-description#
  class TestCase
    TEST_DIR = File.join(File.dirname(__FILE__), 'xhtml1-testcases')
    
    attr_accessor :about
    attr_accessor :name
    attr_accessor :contributor
    attr_accessor :title
    attr_accessor :informationResourceInput
    attr_accessor :originalInformationResourceInput
    attr_accessor :informationResourceResults
    attr_accessor :originalInformationResourceResults
    attr_accessor :purpose
    attr_accessor :reviewStatus
    attr_accessor :specificationReference
    attr_accessor :expected_results
    
    @@test_cases = []
    
    def initialize(statements)
      expected_results = true
      statements.each do |statement|
        next if statement.subject.is_a?(Redland::BNode)
        unless self.about
          self.about = URI.parse(statement.subject.uri.to_s)
          self.name = statement.subject.uri.short_name
        end
        
        if statement.predicate.uri.short_name == "informationResourceInput"
          self.informationResourceInput = statement.object.uri.to_s.sub!(/^.*xhtml1-testcases/, TEST_DIR)
          self.originalInformationResourceInput = statement.object.uri.to_s
        elsif statement.predicate.uri.short_name == "informationResourceResults"
          self.informationResourceResults = statement.object.uri.to_s.sub!(/^.*xhtml1-testcases/, TEST_DIR)
          self.originalInformationResourceResults = statement.object.uri.to_s
        elsif self.respond_to?("#{statement.predicate.uri.short_name}=")
          s = case
          when statement.object.literal?  then statement.object.literal
          when statement.object.resource? then statement.object.uri
          when statement.object.blank?    then statement.object.blank_identifier
          else false
          end
          self.send("#{statement.predicate.uri.short_name}=", s.to_s)
        end
      end
    end
    
    def information
      %w(purpose specificationReference).map {|a| v = self.send(a); "#{a}: #{v}" if v}.compact.join("\n")
    end
    
    def self.parse_test_cases
      return unless @@test_cases.empty?
      
      manifest = File.read(File.join(TEST_DIR, "rdfa-xhtml1-test-manifest.rdf"))
      rdfxml_parser = Redland::Parser.new
      test_hash = {}
      rdfxml_parser.parse_string_as_stream(manifest, "http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/rdfa-xhtml1-test-manifest.rdf") do |st|
        a = test_hash[st.subject.uri.to_s] ||= []
        a << st
      end
      
      @@test_cases = test_hash.values.map {|statements| TestCase.new(statements)}.
        compact.
        select{|t| t.reviewStatus == "http://www.w3.org/2006/03/test-description#approved"}.
        sort_by{|t| t.about.is_a?(URI) ? t.about.to_s : "zzz"}
    end
    
    def self.test_cases; parse_test_cases; @@test_cases; end
  end
end


class Redland::Uri
  def short_name
    u = URI.parse(self.to_s)
    if u.fragment
      return u.fragment
    elsif u.path.split("/").last.class == String and u.path.split("/").last.length > 0
      return u.path.split("/").last
    else
      return false
    end
  end
end

# Simple parser for NTriples
class NTriplesParser
  attr_reader :graph

  def initialize(string)
    @graph = RdfaParser::Graph.new
    RdfaParser::BNode.reset
    
    ntriples_parser = Redland::Parser.ntriples
    ntriples_parser.parse_string_as_stream(string, "http://www.w3.org/2006/07/SWD/RDFa/testsuite/xhtml1-testcases/") do |st|
      s = redland_to_native(st.subject)
      p = redland_to_native(st.predicate)
      o = redland_to_native(st.object)
      @graph.add_triple(s, p, o)
    end
  end
  
  def redland_to_native(resource)
#    puts resource.inspect
    case
    when resource.literal?
      node_type = Redland.librdf_node_get_literal_value_datatype_uri(resource.literal.node)
      node_type = RdfaParser::URIRef.new(Redland.librdf_uri_to_string(node_type)) if node_type
      RdfaParser::Literal.new(resource.literal.value, node_type, resource.literal.language)
    when resource.blank?
      # Cache anonymous blank identifiers
      @bn_hash ||= {}
      id = resource.blank_identifier.to_s
      id = nil if id.match(/^r[r\d]+$/)
      bn = @bn_hash[resource.blank_identifier.to_s] ||= RdfaParser::BNode.new(id)
      bn.identifier
      bn
    when resource.resource?
      RdfaParser::URIRef.new(resource.uri.to_s)
    else
      nil
    end
  end
end