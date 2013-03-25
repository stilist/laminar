module Twitter
	def self.person_url data
		"https://twitter.com/#{data["user"]["screen_name"]}"
	end

	def self.media data
		out = ""

		media = eval(data["entities"])["media"]
		media.each do |item|
			out << "<a href='#{item["expanded_url"]}'>
				<img src='#{item["media_url_https"]}'>
			</a>"
		end

		out
	end

	def self.tweet_url data
		person_url(data) << "/status/#{data["id_str"]}"
	end

	def self.text data={}
		tweet = data["text"]

		urls = eval(data["entities"])["urls"]
		urls.each { |url| tweet[url["url"]] = url["expanded_url"] }

		media = eval(data["entities"])["media"]
		media.each { |url| tweet[url["url"]] = url["expanded_url"] }

		out = tweet.gsub /@(\w+)/, %Q{@<a href="http://twitter.com/\\1">\\1</a>}

		Rinku.auto_link out
	end
end
