require 'rubygems'
require 'xml/libxml'
[
  %{<html><body><p xmlns:xml="http://www.w3.org/XML/1998/namespace">Test</p></body></html>},
  %{<html><body><p xmlns:foo="http://foo.bar">Test</p></body></html>},
].each do |tc|
  d = XML::Parser.string(tc).parse
  puts d.find_first("//p").namespaces.first
end;nil
