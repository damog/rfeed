class Post < ActiveRecord::Base
	belongs_to :feed
	validates_presence_of :entry_id, :feed_id, :title, :link

end
