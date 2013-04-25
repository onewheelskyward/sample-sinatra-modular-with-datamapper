class Generic
	include DataMapper::Resource

	property :id, Serial
	property :sometext, Text
	property :created_at, DateTime
	property :updated_at, DateTime
end
