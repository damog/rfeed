class InitialSchemaMigration < Sequel::Migration
	def up
		create_table :feeds do
			primary_key :id
			varchar :link
			varchar :feed_url
			varchar :title
			varchar :etag
			timestamp :last_modified
			timestamp :created_at
			timestamp :updated_at
		end

		create_table :posts do
			primary_key :id

			varchar :entry_id
			integer :feed_id
			text :title
			text :link
			text :description
			timestamp :date
			timestamp :updated_at
			timestamp :last_processed_at
		end
	end

	def down
		drop_table :feeds
		drop_table :posts
	end
end
