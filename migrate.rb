#
# David Moreno <david@axiombox.com>
#

require "#{File.expand_path(File.dirname(__FILE__))}/config.rb"

Sequel::Migrator.apply(DB, "migrations")
