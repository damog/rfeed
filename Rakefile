#
# David Moreno <david@axiombox.com>
#

require "#{File.expand_path(File.dirname(__FILE__))}/lib/rfeed.rb"
require "mysql"

task :default => :"db:migrate"

task :'db:migrate' => :environment do
	ActiveRecord::Migrator.migrate("#{File.dirname(__FILE__)}/db/migrate", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end

task :environment do
	ActiveRecord::Base.logger = Logger.new(File.open("#{File.dirname(__FILE__)}/log/database.log", "a"))
end

