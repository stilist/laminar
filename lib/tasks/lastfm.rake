namespace :lastfm do
	$lastfm = Lastfm.new ENV["LASTFM_API_KEY"], ENV["LASTFM_API_SECRET"]
	$long_sleep = 5
	$session = ENV["LASTFM_CLIENT_KEY"]
	$source = "lastfm"
	$token = $lastfm.auth.get_token
	$user = ENV["LASTFM_USER"]

	if $session
		$lastfm.session = $session
	else
		abort "You need to authorize Laminar on last.fm. Run: rake lastfm:authorize"
	end

	task :authorize do
		puts "Open this URL in your browser to authorize Laminar:"
		puts "http://www.last.fm/api/auth/?api_key=#{ENV["LASTFM_API_KEY"]}&token=#{$token}"
		puts
		puts "Hit return/enter after granting access"
		STDIN.gets

		client_key = $lastfm.auth.get_session(token: $token)["key"]
		puts "export LASTFM_CLIENT_KEY=#{client_key}"
	end

	task :plays do ; get_lastfm_plays(false) end
	task :backfill_plays do ; get_lastfm_plays(true) end

	private

	def get_lastfm_plays paginate=false
		total = $lastfm.user.get_info(user: $user)["playcount"].to_i
		per_page = 200 # max: 200
		pages = paginate ? (total / per_page.to_f).ceil : 1

		puts
		puts "*** #{total} tracks played"

		1.upto(pages).each_with_index do |page, p_idx|
			puts "  * page #{p_idx + 1}/#{pages}"

			items = $lastfm.user.get_recent_tracks({
				limit: per_page,
				user: $user,
				page: page,
				extended: 1
			})
			# Not sure why it doesn't always come through as an `Array`.
			items = [items] if items.is_a? Hash
			items.delete_at(0) if items.first["nowplaying"]

			add_lastfm_items items, "play"

			sleep $long_sleep if paginate
		end
	end

	def add_lastfm_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item["artist"]["name"]}--#{item["name"]} [#{idx + 1}/#{total}]"

				original_id = item["mbid"]

				existing = Activity.where(original_id: original_id).first
				existing_name = existing ? "#{existing.original_id}#{existing.activity_type}" : ""

				unless existing && existing_name == "#{original_id}#{activity_type}"
					timestamp = Time.at item["date"]["uts"].to_i
					Activity.create({
						source: $source,
						activity_type: activity_type,
						url: item["url"],
						created_at: timestamp,
						updated_at: timestamp,
						data: item,
						original_id: original_id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
