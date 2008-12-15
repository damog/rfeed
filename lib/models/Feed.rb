class Feed < ActiveRecord::Base
	has_many :posts

	validates_presence_of :link, :feed_url

end
