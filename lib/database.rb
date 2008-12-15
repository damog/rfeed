#
# David Moreno <david@axiombox.com>
#

# old version using Sequel
# DB = Sequel.connect("mysql://root@localhost/rfeed_test")

dyml = "#{File.dirname(__FILE__)}/../config/database.yml"
DB = YAML::load(File.open(dyml))

ActiveRecord::Base.establish_connection(DB)
