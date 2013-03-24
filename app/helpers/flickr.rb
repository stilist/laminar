module Flickr
	def person_url data
		"http://www.flickr.com/photos/#{data["owner"]}"
	end

	def photo_source_url data, size="o"
		data = eval(data) unless data.is_a? Hash
		secret = (size == "o") ? data["originalsecret"] : data["secret"]
		"http://farm#{data["farm"]}.staticflickr.com/#{data["server"]}/#{data["id"]}_#{secret}_#{size}.jpg"
	end
end
