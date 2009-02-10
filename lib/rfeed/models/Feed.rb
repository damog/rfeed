require "rfeedparser"
require "feedbag"
require "goodies/goodies/lwr-simple"
require 'digest/md5'

class Feed < ActiveRecord::Base
	has_many :posts

	validates_presence_of :feed_url, :message => "wasn't found"
	validates_presence_of :link, :message => "wasn't found on `feed_url'"
	validates_uniqueness_of :feed_url, :message => "already exists on database"

	attr_accessor :fp, :url
	
	before_validation_on_create :before_created
	before_validation_on_update :before_updated
	
	def before_created
    self.url = LWR::Simple.normalize(self.url).to_s

    # checking that the url is a feed:
    feedbag = Feedbag.find(url)
    if feedbag.size == 1 and feedbag.first == url
      # si es
    elsif feedbag.first.nil?
      $stderr.puts "URL not a feed and not feeds found"
      return false
    else
      self.url = feedbag.first
      $stderr.puts "URL provided not a feed but using `#{url}'"
    end

    self.feed_url = self.url
		fp = FeedParser.parse self.url

		if fp.status.nil? or fp.status >= 400.to_s
      $stderr.puts "Errors with #{url}!"
      return false
    end

		if fp.status == "304" and fp.feed.empty? and fp.entries.empty? # not changed!
			return false
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
        v.validate_url self.url
        unless v.valid?
          $stderr.puts "Invalid feed"
          return false
        end
      end
    end
    
    self.link = fp.feed.link
    self.title = fp.feed.title
    true # if i made it this far, it was successful callback  
	end
	

	def name
		return "#{self.id}:#{self.feed_url}"
	end

	def before_updated
	  self.fp = FeedParser.parse self.feed_url, { :etag => self.etag, :modified => self.last_modified }
	
		if self.fp.status.nil? or self.fp.status >= 400.to_s
      $stderr.puts "Errors with #{self.feed_url}!"
      return false
    end

		if self.fp.status == "304" and self.fp.feed.empty? and self.fp.entries.empty? # not changed!
		  $stderr.puts "Feed unchanged (not updating)!"
			return false
		end
    
		self.link = self.fp.feed.link
		self.title = self.fp.feed.title
		self.etag = self.fp.etag
		self.last_modified = self.fp.modified_time
		
    # TODO: Find a good way to reset the feed_url when changed
		# self.feed_url =
		
		self.fp.entries.each do |e|
		  post = Post.new :e => e
		end
		
		true 
	end

	def fetch
		parse(self.feed_url, :etag => self.etag, :modified => self.last_modified)

	  # unless self.changed
	 #     puts "#{self.name}: Feed unchanged"
	 #     return
	 #   end

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


end
