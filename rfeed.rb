#
# David Moreno <david@axiombox.com>
#

# gems
[
	"rubygems",
	"activerecord",
	"yaml",
].each do |r|
	require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/lib/models/*.rb"].each do |r|
  require "#{r}"
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/lib/*.rb"].each do |r|
	require "#{r}"
end

module Rfeed
	def self.version
		"0.1"
	end
end

