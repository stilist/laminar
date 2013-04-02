module Twttr
	def self.person_url data
		user = data["user"].is_a?(String) ? eval(data["user"]) : data["user"]
		"https://twitter.com/#{user["screen_name"]}"
	end

	def self.person_link data
		user = data["user"].is_a?(String) ? eval(data["user"]) : data["user"]
		"<a href='https://twitter.com/#{user["screen_name"]}'>#{user["name"]}</a>"
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

	def self.client
		client = Twitter::Client.new({
			consumer_key: ENV["TWITTER_APP_KEY"],
			consumer_secret: ENV["TWITTER_APP_SECRET"],
			oauth_token: ENV["TWITTER_USER_KEY"],
			oauth_token_secret: ENV["TWITTER_USER_SECRET"]
		})

		# https://github.com/sferik/twitter/issues/370#issuecomment-15495843
		# (also: https://dev.twitter.com/discussions/15989)
		client.send(:connection).headers["Connection"] = ""

		client
	end
end