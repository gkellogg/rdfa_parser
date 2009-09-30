require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/rdfa_parser'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'rdfa_parser' do
  self.developer            'Gregg Kellogg', 'gregg@kellogg-ssoc.com'
  self.rubyforge_name       = "rdfa-parser"
  self.url                  = "http://fixme"
  self.extra_deps           = [
    ['addressable', '>= 2.0.0'],
    ['nokogiri',    '>= 1.3.3']
  ]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
