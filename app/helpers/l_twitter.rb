module LTwitter
	@options = {
		count: 200,
		include_entities: true
	}

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

	def self.get_favorites use_max_id=false
		activity_type = "favorite"
		delay = (15 * 60) / 15

		items = self.get_remote_data :favorites, activity_type, use_max_id
		Laminar.add_items "twitter", activity_type, items

		if use_max_id and items.length == @options[:count]
			sleep delay

			self.get_favorites true
		end
	end

	def self.get_tweets use_max_id=false
		activity_type = "post"
		delay = (15 * 60) / 180

		items = self.get_remote_data :user_timeline, activity_type, use_max_id
		Laminar.add_items "twitter", activity_type, items

		if use_max_id and items.length == @options[:count]
			sleep delay

			self.get_tweets true
		end
	end

	private

	def self.get_remote_data method, activity_type, use_max_id
		settings = {}.merge(@options)

		item = Activity.where(source: "twitter").where(activity_type: activity_type)

		if use_max_id
			oldest = item.last
			settings.merge!({ max_id: oldest["data"]["id"] }) if oldest
		else
			newest = item.first
			settings.merge!({ since_id: newest["data"]["id"] }) if newest
		end

		raw_items = self.client.send method, ENV["TWITTER_USER"], settings
		self.preprocess_data raw_items
	end

	def self.preprocess_data raw_items
		raw_items.map do |item|
			# `.attrs` use: http://stackoverflow.com/a/13249551/672403
			item = item.respond_to?(:attrs) ? item.attrs : item
			data = Laminar.sym2s item

			id = data["id_str"]
			time = Time.parse(data["created_at"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => data,
				"url" => "https://twitter.com/#{data["user"]["screen_name"]}/status/#{id}",
				"original_id" => id
			}
		end
	end

	def self.process_local_data
		puts "-----> Twitter: processing tweet data"

		data_path = File.expand_path "sources/tweets/data/js/tweets"
		out = []

		Dir.chdir(data_path) do
			Dir.glob("*.js") do |path|
				# http://stackoverflow.com/a/14060317/672403
				items = JSON.parse(File.readlines(path)[1..-1].join())
				out << self.preprocess_data(items)
			end
		end

		out.flatten 1
	end
end
