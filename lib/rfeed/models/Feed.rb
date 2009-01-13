require "rfeedparser"
require "feedbag"
require "goodies/goodies/lwr-simple"
require 'digest/md5'

class FeedParserRFeed < FeedParser
	def initialize
	end

	def parse
	end
end

class Feed < ActiveRecord::Base
	has_many :posts

	validates_presence_of :feed_url, :message => "wasn't found"
	validates_presence_of :link, :message => "wasn't found on `feed_url'"
	validates_uniqueness_of :feed_url, :message => "already exists on database"

	attr_accessor :fp, :changed

	def name
		return "#{self.id}:#{self.feed_url}"
	end

	def parse(url, params = {})
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

		fp = FeedParser.parse url, { :etag => params[:etag], :modified => params[:modified] }

		if fp.status.nil? or fp.status >= 400.to_s
      $stderr.puts "Errors with #{url}!"
      return nil
    end

		if fp.status == "304" and fp.feed.empty? and fp.entries.empty? # not changed!
			self.changed = false
			return self
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
		if params[:new]
			self.etag = nil
			self.last_modified = nil
		else
			puts "ahh!"
			self.etag = fp.etag
			self.last_modified = fp.modified_time
		end
		self.feed_url = url
		self.changed = true
		self.fp = fp
		self
	end

	def fetch
		parse(self.feed_url, :etag => self.etag, :modified => self.last_modified)

		unless self.changed
			puts "#{self.name}: Feed unchanged"
			return
		end

		self.fp.entries.each do |e|
			post = Post.entry(e, self)
		end

		self.save

		if feed.save
			puts "#{feed.name} successfully fetched!"
		else
			puts feed.errors.full_messages
			pp feed
		end
	end

	def feed=(url)
		p = self.parse(url, :new => true)

		if p.nil?
			return nil
		end
	end
end
