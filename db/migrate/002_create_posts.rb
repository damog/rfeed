class CreatePosts < ActiveRecord::Migration
	def self.up
		create_table :posts do |p|
			p.string :entry_id
			p.integer :feed_id
			p.string :title
			p.string :link
			p.text :description
			p.timestamp :date
			p.timestamp :updated_at
			p.timestamp :last_processed_at
		end
	end

	def self.down
		drop_table :posts
	end

end
