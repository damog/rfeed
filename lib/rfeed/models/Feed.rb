require "rfeedparser"
require "feedbag"
require "terminator"
require "goodies/goodies/lwr-simple"
require 'digest/md5'

Hpricot.buffer_size = 262144

class Feed < ActiveRecord::Base
	has_many :posts

	validates_presence_of :feed_url, :message => "wasn't found"
	validates_presence_of :link, :message => "wasn't found on `feed_url'"
	validates_uniqueness_of :feed_url, :message => "already exists on database"

	attr_accessor :fp, :url
	
	before_validation_on_create :before_created
	before_validation_on_update :before_updated
	before_destroy :before_destroyed
	
	def name
		return "#{self.id}:#{self.feed_url}"
	end
	
	protected
	
	def before_destroyed
	  self.posts.each do |p|
	    p.destroy
	  end
	end
	
	def before_created
	  unless self.url
	    self.errors.add :feed_url, "was not specified"
	    return false
	  end
	  
	  # there's very few cases where the normalized url could be
	  # fucked up, this is not exactly a bug on LWR
	  begin
      self.url = LWR::Simple.normalize(self.url).to_s
    rescue => ex
      $stderr.puts "Unrecoverable error with `#{self.url}' on #{ex.class}:"
      $stderr.puts " #{ex.message}"
      self.errors.add :feed_url, "was fucked up"
      return false
    end

    # checking that the url is a feed:
    feedbag = Feedbag.find(url)
    if feedbag.size == 1 and feedbag.first == url
      # si es
    elsif feedbag.first.nil?
      self.errors.add :feed_url, "not a feed and not feeds found"
      return false
    else
      self.url = feedbag.first
      $stderr.puts "URL provided not a feed but using `#{url}'"
    end

    self.feed_url = self.url

    fp = nil
    begin
      Terminator.terminate 20 do
        fp = FeedParser.parse self.url
      end
    rescue Terminator::Error => ex
      self.errors.add :feed_url, "- #{ex.class} error ocurred: #{ex.message}"
      return false
    rescue
      self.errors.add :feed_url, "- Internal malfunction, mail developers"
      return false
    end

		if fp.status.nil? or fp.status >= 400.to_s
		  self.errors.add :feed_url, "couldn't be fetched or returned HTTP bad code"
      return false
    end

		if fp.status == "304" and fp.feed.empty? and fp.entries.empty? # not changed!
		  self.errors.add :feed_url, "unchanged or empty"
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
          self.errors.add :feed_url, "didn't look like a feed and didn't pass the w3c validation"
          return false
        end
      end
    end
    
    self.link = fp.feed.link || self.feed_url
    self.title = fp.feed.title
    true # if i made it this far, it was successful callback  
	end

	def before_updated
    $stdout.puts "=> #{self.feed_url}"
    begin
      Terminator.terminate 20 do
        if self.etag and self.last_modified
          puts "Both etag and last_modified"
          self.fp = FeedParser.parse self.feed_url, { :etag => self.etag, :modified => self.last_modified }
        elsif self.etag
          puts "Only etag"
          self.fp = FeedParser.parse self.feed_url, { :etag => self.etag }
        elsif self.last_modified
          puts "Only last_modified"
          self.fp = FeedParser.parse self.feed_url, { :modified => self.last_modified }
        else
          puts "Neither etag or last_modified"
          self.fp = FeedParser.parse self.feed_url
        end
      end
    rescue Terminator::Error => ex
      self.errors.add :feed_url, "- #{ex.class} error ocurred: #{ex.message}"
      return false
    rescue
      self.errors.add :feed_url, "- Internal malfunction"
      return false
    end

	
		if self.fp.status.nil? or self.fp.status >= 400.to_s
		  self.errors.add :feed_url, "couldn't be fetched or returned HTTP bad code"
      return false
    end

		if self.fp.status == "304" and self.fp.feed.empty? and self.fp.entries.empty? # not changed!
		  self.errors.add :feed_url, "unchanged or empty"
			return false
		end
    
		self.link = self.fp.feed.link || self.feed_url 
		self.title = self.fp.feed.title unless self.title
		self.etag = self.fp.etag
		self.last_modified = self.fp.modified_time
		
    # TODO: Find a good way to reset the feed_url when changed
		# self.feed_url =
		
		self.fp.entries.each do |e|
		  post = Post.entry(e, self)
		  if post
		    if post.save
		      puts "Successfully created #{post.entry_id}"
		    end
		  end
      # post = Post.new :e => e
      # if post.save
      #   puts "Successfully saved #{post.entry_id}"
      # else
      #   puts "Error with #{pp e}"
      # end
		end
		
		true 
	end


end
