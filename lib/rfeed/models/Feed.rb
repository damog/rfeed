require "rfeedparser"
require "feedbag"
require "goodies/goodies/lwr-simple"

class Feed < ActiveRecord::Base
	has_many :posts

	validates_presence_of :feed_url, :message => "wasn't found"
	validates_presence_of :link, :message => "wasn't found on `feed_url'"
	validates_uniqueness_of :feed_url, :message => "already exists on database"

	attr_accessor :fp

	def parse(url)
    url = LWR::Simple.normalize(url).to_s

    # checking that the url is a feed:
    feedbag = Feedbag.find(url)
    if feedbag.size == 1 and feedbag.first == url
      # si es
    elsif feedbag.first.nil?
      $stderr.puts "URL not a feed and not feeds found"
      return nil
    else
      url = feedbag.first
      $stderr.puts "URL provided not a feed but using `#{url}'"
    end

		fp = FeedParser.parse url

		if fp.status.nil? or fp.status >= 400.to_s
      $stderr.puts "Errors with #{url}!"
      return nil
    end

    # there's no real easy way to do this
    # so we'll only do if the feed_validator gem is available
    validate = false # assuming it's not there
    if fp.entries.empty?
      begin
        require "feed_validator"
        validate = true
      rescue LoadError
        $stderr.puts "Not using feed_validator"
      end

      if validate
        v = W3C::FeedValidator.new
        v.validate_url url
        unless v.valid?
          $stderr.puts "Invalid feed"
          return nil
        end
      end
    end
		
		self.link = fp.feed.link
		self.title = fp.feed.title
		self.etag = fp.etag
		self.last_modified = fp.modified_time
		self.feed_url = url
		self.fp = fp
	end

	def update
		p = self.parse(self.feed_url)

		p.entries.each do |e|
#			Post.new  !!!!
		end
	end

	def feed=(url)
		p = self.parse(url)

		if p.nil?
			return nil
		end
	end
end
