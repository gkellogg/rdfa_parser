require 'rubygems'
begin
  gem 'jeweler'
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "rdfa_parser"
    gemspec.summary = "[Deprecated] RDFa parser written in pure Ruby."
    gemspec.description = "This gem is no longer supported, please see http://rubygems.org/gems/rdf-rdfa"
    gemspec.email = "gregg@kellogg-assoc.com"
    gemspec.homepage = "http://github.com/gkellogg/rdfa_parser"
    gemspec.authors = ["Gregg Kellogg"]
    gemspec.add_dependency('addressable', '>= 2.0.0')
    gemspec.add_dependency('nokogiri', '>= 1.3.3')
    gemspec.add_dependency('builder', '>= 2.1.2')
    gemspec.add_development_dependency('rspec')
    gemspec.add_development_dependency('activesupport', '>= 2.3.0')
    gemspec.extra_rdoc_files     = %w(README.rdoc History.txt)
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
