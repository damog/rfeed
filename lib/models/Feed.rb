class DBFeed < Sequel::Model(DB[:feeds])
	has_many :posts

end
