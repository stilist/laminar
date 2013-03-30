module Flickr
	def self.person_url data
		"http://www.flickr.com/photos/#{data["owner"]}"
	end

	def self.photo_url data
		# http://stackoverflow.com/a/3908411/672403
		owner = data["owner"]
		if owner.is_a?(String)
			# Catch serialized `Hash`
			person = owner[0] == "{" ? eval(data["owner"])["nsid"] : owner
		else
			person = data["owner"]["nsid"]
		end

		"http://www.flickr.com/photos/#{person}/#{data["id"]}/"
	end

	def self.photo_source_url data, size="o"
		data = eval(data) unless data.is_a? Hash
		secret = (size == "o") ? data["originalsecret"] : data["secret"]
		"http://farm#{data["farm"]}.staticflickr.com/#{data["server"]}/#{data["id"]}_#{secret}_#{size}.jpg"
	end
end
