class CreateFeeds < ActiveRecord::Migration
	def self.up
		create_table :feeds do |f|
			f.string :link
			f.string :feed_url
			f.string :title
			f.string :etag
			f.timestamp :last_modified
			f.timestamp :created_at
			f.timestamp :updated_at
		end
	end

	def self.down
		drop_table :feeds
	end

end
