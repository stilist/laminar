module Twitter
	def self.person_url data
		"https://twitter.com/#{data["user"]["screen_name"]}"
	end

	def self.tweet_url data
		person_url(data) << "/status/#{data["id_str"]}"
	end

	def self.text data=""
		data.gsub(/@(\w+)/, %Q{@<a href="http://twitter.com/\\1">\\1</a>})
	end
end
