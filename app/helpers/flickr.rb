module Flickr
	def self.person_url data
		"http://www.flickr.com/photos/#{data["owner"]}"
	end

	def self.photo_url data
		# Detect stringified `Hash`
		person = (data["owner"] =~ /{/) ? eval(data["owner"])["nsid"] : data["owner"]
		"http://www.flickr.com/photos/#{person}/#{data["id"]}/"
	end

	def self.photo_source_url data, size="o"
		data = eval(data) unless data.is_a? Hash
		secret = (size == "o") ? data["originalsecret"] : data["secret"]
		"http://farm#{data["farm"]}.staticflickr.com/#{data["server"]}/#{data["id"]}_#{secret}_#{size}.jpg"
	end
end
