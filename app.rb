require 'sinatra'
require "sinatra/reloader" if development?
require 'data_mapper'
#require 'dm-sqlite-adapter'
require 'dm-postgres-adapter'
require_relative 'helpers'

DataMapper::Logger.new($stdout, :debug)
DataMapper::Property::String.length(4000)
DataMapper.setup(:default, "sqlite://#{File.expand_path(File.dirname(__FILE__))}/sample.sqlite")
#DataMapper.setup(:default, "postgres://localhost/database")

Dir.glob("models/*.rb").each { |file| require_relative file }

DataMapper.finalize
DataMapper.auto_upgrade!
# DataMapper.auto_migrate!  # This one wipes the database out every time.  Good for testing.

class App < Sinatra::Base
	get '/' do
		erb :basic, :locals => {local_erb_var: "xyz"}
	end
end
