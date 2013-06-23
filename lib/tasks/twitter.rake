# `static_tweets_local` processes the data from Twitter's archive

namespace :twitter do
	@options = {
		count: 200,
		include_entities: true
	}

	task :favorites do ; get_favorites end
	task :backfill_favorites do ; get_favorites true end

	task :tweets do ; get_tweets end
	task :backfill_tweets do ; get_tweets true end

	task :static_tweets_local do
		items = process_local_data
		Laminar.put_static_data ENV["TWITTER_TWEETS_FILENAME"], items
	end

	task :static_tweets_remote do
		items = Laminar.get_static_data ENV["TWITTER_STATIC_TWEETS_URL"]
		Laminar.add_items "twitter", "post", items
	end

	private

	def get_favorites use_max_id=false
		activity_type = "favorite"
		delay = (15 * 60) / 15

		items = get_remote_data :favorites, activity_type, use_max_id
		Laminar.add_items "twitter", activity_type, items

		if use_max_id and items.length == @options[:count]
			sleep delay

			get_favorites true
		end
	end

	def get_tweets use_max_id=false
		activity_type = "post"
		delay = (15 * 60) / 180

		items = get_remote_data :user_timeline, activity_type, use_max_id
		Laminar.add_items "twitter", activity_type, items

		if use_max_id and items.length == @options[:count]
			sleep delay

			get_tweets true
		end
	end

	def get_remote_data method, activity_type, use_max_id
		settings = {}.merge(@options)

		item = Activity.where(source: "twitter").where(activity_type: activity_type)

		if use_max_id
			oldest = item.last
			settings.merge!({ max_id: oldest["data"]["id"] }) if oldest
		else
			newest = item.first
			settings.merge!({ since_id: newest["data"]["id"] }) if newest
		end

		raw_items = LTwitter.client.send method, ENV["TWITTER_USER"], settings
		preprocess_data raw_items
	end

	def preprocess_data raw_items
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

	def process_local_data
		puts "-----> Twitter: processing tweet data"

		data_path = File.expand_path "sources/tweets/data/js/tweets"
		out = []

		Dir.chdir(data_path) do
			Dir.glob("*.js") do |path|
				# http://stackoverflow.com/a/14060317/672403
				items = JSON.parse(File.readlines(path)[1..-1].join())
				out << preprocess_data(items)
			end
		end

		out.flatten 1
	end
end
