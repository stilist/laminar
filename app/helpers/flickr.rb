module Flickr
	def self.person_url data
		"http://www.flickr.com/photos/#{data["owner"]}"
	end

	def self.photo_url data
		# http://stackoverflow.com/a/3908411/672403
		person = case data["owner"]
			when String then data["owner"]
			when Hash then data["owner"]["nsid"]
			# stringified `Hash`
			else eval(data["owner"])["nsid"]
		end

		"http://www.flickr.com/photos/#{person}/#{data["id"]}/"
	end

	def self.photo_source_url data, size="o"
		data = eval(data) unless data.is_a? Hash
		secret = (size == "o") ? data["originalsecret"] : data["secret"]
		"http://farm#{data["farm"]}.staticflickr.com/#{data["server"]}/#{data["id"]}_#{secret}_#{size}.jpg"
	end
end
