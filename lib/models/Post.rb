class DBPost < Sequel::Model(DB[:posts])
	belongs_to :feed
end
