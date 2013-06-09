module LTwitter
	def self.get_user data
		data["user"].is_a?(String) ? eval(data["user"]) : data["user"]
	end

	def self.person_url data
		user = get_user data
		"https://twitter.com/#{user["screen_name"]}"
	end

	def self.person_link data
		user = get_user data
		"<a href='https://twitter.com/#{user["screen_name"]}'>#{user["name"]}</a>"
	end

	def self.first_mention data
		mention = eval(data["entities"])["user_mentions"].first
		Laminar.sym2s(mention)["name"]
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

	def self.text data={}, autolink=true
		data = eval(data["retweeted_status"]) if data["retweeted_status"]
		tweet = data["text"]
		if data["entities"].is_a? String
			entities = eval(data["entities"])
		else
			entities = data["entities"]
		end

		urls = entities["urls"] || entities[:urls]
		if urls
			urls.each do |url|
				if tweet[url["url"] || url[:url]]
					tweet[url["url"] || url[:url]] = url["expanded_url"] || url[:expanded_url]
				end
			end
		end

		media = entities["media"] || entities[:media]
		if media
			media.each do |url|
				if tweet[url["url"] || url[:url]]
					tweet[url["url"] || url[:url]] = url["expanded_url"] || url[:expanded_url]
				end
			end
		end

		if autolink
			out = tweet.gsub /@(\w+)/, %Q{@<a href="http://twitter.com/\\1">\\1</a>}

			Rinku.auto_link out
		else
			out
		end
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
