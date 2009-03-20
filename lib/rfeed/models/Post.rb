class Post < ActiveRecord::Base
	belongs_to :feed
	validates_presence_of :entry_id, :feed_id, :title, :link

	validates_uniqueness_of :entry_id
		
	def self.entry(e, feed = nil)
		entry_id = nil
		if not e["id"].nil? and not e["id"].empty? # e.id will try to trigger Object.id
			puts "using id"
			entry_id = e["id"]
		elsif not e.link.empty?
			puts "using link"
			entry_id = e.link
		elsif not e.title.empty?
			puts "using title"
			entry_id = MD5::Digest.hexdigest(e.title)
		elsif not e.summary.empty?
			puts "using summary"
			entry_id = MD5::Digest.hexdigest(e.summary)
		else
			$stderr.puts "No entry_id found for #{pp e}"
      return nil
		end

		post = Post.find_or_create_by_entry_id(entry_id)
		post.feed_id = feed["id"]

    begin
      post.link = e.link || e.links[0]["href"] || feed.link
    rescue
      post.link = "#"
    end
    
		post.title = e.title || e.link
		post.description = e.description || e.content || e.summary || "no content"
		post.date = e.created_time || e.updated_time || e.published_time || feed.fp.updated_time || feed.fp.modified_time || Time.now
		return post
	end

end
