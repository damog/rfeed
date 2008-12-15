#
# David Moreno <david@axiombox.com>
#

[
	"rubygems",
	"activerecord",
	"yaml",
].each do |r|
	require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/lib/*.rb"].each do |r|
	require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/lib/models/*.rb"].each do |r|
  require "#{r}"
end

