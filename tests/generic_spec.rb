require_relative 'spec_helper'
describe 'tests' do
	it 'will run get_something and return for nothing' do
		get '/'
		last_response.body.should_not be nil
	end
end
