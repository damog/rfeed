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

module Rfeed
	def self.version
		"0.1"
	end

	def self.add
		puts "I will add a new feed"
	end

	def self.feed_new(url)

		# validamos primero el link
		# - si no es una URL, error
		# - verificar que rfeedparser pueda leerlo

		unless url =~ /((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?/
			puts "'#{url}' doesn't look like a URL"
			exit 1
		end

		feed = Feed.new
		feed.feed_url = url

		unless feed.save
			puts feed.errors.full_messages
			exit 1
		end

	end

end

