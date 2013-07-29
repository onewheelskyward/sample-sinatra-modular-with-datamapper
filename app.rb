require 'sinatra/base'
require 'data_mapper'
#require 'dm-sqlite-adapter'
require 'dm-postgres-adapter'

DataMapper::Logger.new($stdout, :debug)
DataMapper::Property::String.length(4000)
#DataMapper.setup(:default, "sqlite://#{File.expand_path(File.dirname(__FILE__))}/sample.sqlite")
DataMapper.setup(:default, "postgres://localhost/database")

["models", "helpers", "controllers", "routes"].each do |folder|
	Dir.glob("#{folder}/*.rb").each { |file| require_relative file }
end

DataMapper.finalize
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!  # This one wipes the database out every time.  Good for testing.

class App < Sinatra::Base
	helpers Sinatra::Helpers

	configure :development do
		require 'sinatra/reloader'
		["models", "helpers", "controllers", "routes"].each do |folder|
			Dir.glob("#{folder}/*.rb").each { |file| also_reload file }
		end
	end
end
