namespace :instagram do
	$delay = (60 * 60) / 5000 # max 5000 requests per user/client per hour
	$source = "instagram"

	task :authorize do
		puts "Open this URL in your browser to authorize Laminar:"
		puts Instagram.authorize_url(redirect_uri: ENV["INSTAGRAM_AUTHORIZE_URL"])
	end

	task :likes do ; instagram_fetcher("like", false) end
	task :backfill_likes do ; instagram_fetcher("like", true) end

	task :photos do ; instagram_fetcher("photo", false) end
	task :backfill_photos do ; instagram_fetcher("photo", true) end

	private

	def instagram_fetcher activity_type, use_max_id
		if ENV["INSTAGRAM_CLIENT_KEY"]
			opts = { access_token: ENV["INSTAGRAM_CLIENT_KEY"] }

			existing = Activity.where(activity_type: activity_type).where(source: $source)
			if use_max_id
				oldest = existing.last
				opts.merge!({ max_id: oldest["data"]["id"] }) if oldest
			else
				newest = existing.first
				opts.merge!({ min_id: newest["data"]["id"] }) if newest
			end

			method = case activity_type
			when "like"
				:user_liked_media
			when "photo"
				:user_recent_media
			end
			items = Instagram.send method, opts

			add_instagram_items items, activity_type

			if !items.empty? and use_max_id
				sleep $delay

				instagram_fetcher activity_type, true
			end
		else
			puts "*** You need to authorize Instagram. Run: rake instagram:authorize"
		end
	end

	def add_instagram_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item.id} [#{idx + 1}/#{total}]"

				existing = Activity.where(original_id: item.id.to_s).first
				existing_name = existing ? "#{existing.original_id}#{existing.activity_type}" : ""

				unless existing && existing_name == "#{item.id}#{activity_type}"
					timestamp = Time.at item["created_time"].to_i

					data = {}
					# Without this the `Hashie::Mash` values are effectively serialized
					# as `v.inspect`, and are unusable.
					item.each { |k,v| data[k] = v.is_a?(Hashie::Mash) ? v.to_hash : v }

					Activity.create({
						source: $source,
						activity_type: activity_type,
						url: item["link"],
						created_at: timestamp,
						updated_at: timestamp,
						data: data,
						original_id: item.id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
