#
# David Moreno <david@axiombox.com>
#

# gems
[
	"rubygems",
	"activerecord",
	"yaml",
	"pp",
].each do |r|
	require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/rfeed/models/*.rb"].each do |r|
  require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/rfeed/*.rb"].each do |r|
	require "#{r}"
end

# TODO: Make sure extend.yml is being used
