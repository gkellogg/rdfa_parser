begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift File.dirname(__FILE__)
require 'rdfa_parser'
require 'matchers'

include RdfaParser

Spec::Runner.configure do |config|
  config.include(Matchers)
end
