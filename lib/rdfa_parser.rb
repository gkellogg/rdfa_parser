$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

Dir.glob(File.join(File.dirname(__FILE__), 'rdfa_parser/**.rb')).each { |f| require f }

begin
  require 'nokogiri'
  require 'addressable/uri'
  require 'builder'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'nokogiri'
  gem 'addressable'
  require 'nokogiri'
  require 'addressable/uri'
  require 'builder'
end

module RdfaParser
  LINK_TYPES = %w(
    alternate appendix bookmark cite chapter contents copyright first glossary
    help icon index last license meta next p3pv1 prev role section stylesheet subsection
    start top up
  )

  RDF_TYPE = URIRef.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
  XML_LITERAL = Literal::Encoding.xmlliteral

  XH_MAPPING = {"" => Namespace.new("http://www.w3.org/1999/xhtml/vocab\#", nil)}
end