ENV['RACK_ENV'] = 'test'
require_relative '../app'
require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
Dir.glob('tests/fixtures/*.rb').each { |file| require_relative file.gsub 'tests/', '' }
#require_relative '../db/seed_function'

set environment :test

def app
	App
end

RSpec.configure do |config|
	config.include Sinatra::Helpers
	config.include Rack::Test::Methods
end

#def auth
#	authorize 'admin', 'admin'
#end
