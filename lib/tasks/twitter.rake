# `static_tweets_local` processes the data from Twitter's archive

namespace :twitter do
	task :favorites do
		get_favorites
	end

	task :backfill_favorites do
		get_favorites true
	end

	task :tweets do
		get_tweets
	end

	task :backfill_tweets do
		get_tweets true
	end

	task :static_tweets_local do
		items = process_tweet_data
		upload_to_remote ENV["TWITTER_TWEETS_FILENAME"], items
	end

	task :static_tweets_remote do
		items = Laminar.get_static_data ENV["TWITTER_STATIC_TWEETS_URL"]
		add_items items, "post"
	end

	private

	def get_tweets use_max_id=false
		delay = (15 * 60) / 180 # max 180 requests per user per 15 minutes
		activity_type = "post"

		opts = {
			count: 200, # max: 200
			include_rts: true
		}

		if use_max_id
			oldest = Activity.where(activity_type: activity_type).where(source: "twitter").last
			opts.merge!({ max_id: oldest["data"]["id"] }) if oldest
		else
			newest = Activity.where(activity_type: activity_type).where(source: "twitter").first
			opts.merge!({ since_id: newest["data"]["id"] }) if newest
		end

		items = LTwitter.client.user_timeline ENV["TWITTER_USER"], opts
		add_items items, activity_type

		if items.length == opts[:count] and use_max_id
			sleep delay

			get_tweets true
		end
	end

	def get_favorites use_max_id=false
		delay = (15 * 60) / 15 # max 15 requests per 15 minutes
		activity_type = "favorite"

		opts = {
			count: 200, # max: 200
			include_entities: true
		}

		if use_max_id
			oldest = Activity.where(activity_type: activity_type).where(source: "twitter").last
			opts.merge!({ max_id: oldest["data"]["id"] }) if oldest
		else
			newest = Activity.where(activity_type: activity_type).where(source: "twitter").first
			opts.merge!({ since_id: newest["data"]["id"] }) if newest
		end

		items = LTwitter.client.favorites ENV["TWITTER_USER"], opts
		add_items items, activity_type

		if items.length == opts[:count] and use_max_id
			sleep delay

			get_favorites true
		end
	end

	def add_items items, activity_type
		total = items.length

		puts
		puts "-----> Twitter: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				id = item.is_a?(Hash) ? item["id"] : item.id

				puts "       #{id} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "twitter").
						where(activity_type: activity_type).
						where(original_id: id.to_s).count

				# `.attrs` use: http://stackoverflow.com/a/13249551/672403
				data = item.respond_to?(:attrs) ? item.attrs : item

				if existing == 0
					Activity.create({
						source: "twitter",
						activity_type: activity_type,
						url: "https://twitter.com/#{item["user"]["screen_name"]}/status/#{id}",
						created_at: item["created_at"],
						updated_at: item["created_at"],
						data: Laminar.sym2s(data),
						original_id: id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def process_tweet_data
		puts "-----> Twitter: processing tweet data"

		data_path = File.expand_path "sources/tweets/data/js/tweets"
		out = []

		Dir.chdir(data_path) do
			Dir.glob("*.js") do |path|
				# http://stackoverflow.com/a/14060317/672403
				out << JSON.parse(File.readlines(path)[1..-1].join())
			end
		end

		data = out.flatten 1

		puts "       #{data.length} item(s)"
		data
	end

	def upload_twitter_remote items
		puts "-----> Twitter: uploading tweet data"

		storage = Fog::Storage.new({
			provider: ENV["FOG_PROVIDER"],
			aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
			aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
		})

		directory = storage.directories.get ENV["FOG_DIRECTORY"]
		file = directory.files.get ENV["TWITTER_TWEETS_FILENAME"]

		json = items.to_json

		if file
			file.body = json
			file.public = true
		else
			file = directory.files.create({
				key: ENV["TWITTER_TWEETS_FILENAME"],
				body: json,
				public: true
			})
			puts "export TWITTER_STATIC_TWEETS_URL=#{file.public_url}"
		end

		file.save
	rescue => e
		puts "Failed to upload data:"
		puts e
	end

	def fetch_twitter_json
		unless ENV["TWITTER_STATIC_TWEETS_URL"]
			puts "Please set the TWITTER_STATIC_TWEETS_URL environment variable"
			puts "e.g. export TWITTER_STATIC_TWEETS_URL=http://foobar.s3.amazonaws.com/twitter_tweets.json"
			abort
		end

		data = open(ENV["TWITTER_STATIC_TWEETS_URL"]).read
		JSON.parse data
	rescue OpenURI::HTTPError => e
		abort "Unable to fetch data from TWITTER_STATIC_TWEETS_URL"
	rescue => e
		abort e
	end
end
