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

		items = Twttr.client.user_timeline ENV["TWITTER_USER"], opts
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

		items = Twttr.client.favorites ENV["TWITTER_USER"], opts
		add_items items, activity_type

		if items.length == opts[:count] and use_max_id
			sleep delay

			get_favorites true
		end
	end

	def add_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item.id} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "twitter").
						where(activity_type: activity_type).
						where(original_id: item.id.to_s).unscoped.count

				if existing == 0
					Activity.create({
						source: "twitter",
						activity_type: activity_type,
						url: "https://twitter.com/#{item["user"]["screen_name"]}/status/#{item.id}",
						created_at: item["created_at"],
						updated_at: item["created_at"],
						# `.attrs` use: http://stackoverflow.com/a/13249551/672403
						data: Laminar.sym2s(item.attrs),
						original_id: item.id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
