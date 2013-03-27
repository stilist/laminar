module Twttr
	def self.person_url data
		"https://twitter.com/#{data["user"]["screen_name"]}"
	end

	def self.media data
		out = ""

		entities = eval(data["entities"])
		media = entities["media"] || entities[:media]
		if media
			media.each do |item|
				e_url = item["expanded_url"] || item[:expanded_url]
				https = item["media_url_https"] || item[:media_url_https]
				out << "<a href='#{e_url}'><img src='#{https}'></a>"
			end
		end

		out
	end

	def self.tweet_url data
		person_url(data) << "/status/#{data["id_str"]}"
	end

	def self.text data={}
		tweet = data["text"]
		entities = eval(data["entities"])

		urls = entities["urls"] || entities[:urls]
		if urls
			urls.each do |url|
				tweet[url["url"] || url[:url]] = url["expanded_url"] || url[:expanded_url]
			end
		end

		media = entities["media"] || entities[:media]
		if media
			media.each do |url|
				tweet[url["url"] || url[:url]] = url["expanded_url"] || url[:expanded_url]
			end
		end

		out = tweet.gsub /@(\w+)/, %Q{@<a href="http://twitter.com/\\1">\\1</a>}

		Rinku.auto_link out
	end
end
