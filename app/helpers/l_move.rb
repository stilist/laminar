module LMove
	@@activity_types = {
		"cyc" => "cycling",
		"run" => "running",
		"trp" => "transport",
		"wlk" => "walking"
	}.freeze

	def self.client
		abort "       Please specify MOVES_CLIENT_KEY" unless ENV["MOVES_CLIENT_KEY"]
		@client ||= Moves::Client.new(ENV["MOVES_CLIENT_KEY"])
	end

	def self.get_storyline backfill=false
		if backfill
			start = DateTime.parse client.profile["profile"]["firstDate"]
		else
			start = DateTime.now - 3
		end

		range = (start..DateTime.now)
		range.each do |date|
			sleep self.rate_limit

			fmt = date.strftime "%Y-%m-%d"

			data = client.daily_storyline fmt, trackPoints: true
			items = self.process_data data[0]["segments"]

			# if there’s no data for the day `process_data` returns `nil`
			next unless items

			Laminar.add_items "moves", "storyline", items, { replace: true }
		end
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "storyline"
			parsed[:start_time] = self.parse_time activity["startTime"]
			parsed[:end_time] = self.parse_time activity["endTime"]
			parsed[:type] = activity["type"]

			if activity["activities"]
				parsed[:activity] = activity["activities"].map do |a|
					out = {
						start_time: self.parse_time(a["startTime"]),
						end_time: self.parse_time(a["endTime"]),
						type: @@activity_types[a["activity"]]
					}

					if a["trackPoints"]
						out[:points] = a["trackPoints"].map do |tp|
							{
								lat: tp["lat"],
								lng: tp["lon"],
								time: self.parse_time(tp["time"])
							}
						end
					end

					out
				end
			end

			if activity["place"]
				parsed[:place] = Laminar.s2sym activity["place"]
				parsed[:place][:location][:lng] = parsed[:place][:location].delete :lon
			end
		end

		parsed
	end

	def self.parse_locations data, activity_type
		out = []

		if data["place"]
			place = eval data["place"]
			location = place["location"]

			out << {
				is_path: false,
				name: place["name"],
				lat: location["lat"],
				lng: location["lon"],
				arrived_at: self.parse_time(data["startTime"]),
				departed_at: self.parse_time(data["endTime"])
			}
		end

		if data["activities"]
			activity = eval data["activities"]
			activity.each do |activity|
				activity_type = @@activity_types[activity["activity"]]

				activity["trackPoints"].each do |point|
					out << {
						is_path: true,
						location_type: activity_type,
						lat: point["lat"],
						lng: point["lon"],
						arrived_at: self.parse_time(point["time"])
					}
				end
			end
		end

		out
	end

	def self.get_access_token code=""
		base = "https://api.moves-app.com/oauth/v1/access_token"
		params = {
			grant_type: "authorization_code",
			code: code,
			client_id: ENV["MOVES_API_KEY"],
			client_secret: ENV["MOVES_API_SECRET"],
			redirect_uri: ENV["MOVES_AUTHORIZE_URL"]
		}.map { |k,v| "#{k}=#{v}" }.join "&"

		response = HTTParty.post "#{base}?#{params}"

		JSON.parse response.body
	end

	private

	def self.parse_time timestamp ; Time.parse(timestamp).getlocal.iso8601 end

	def self.process_data raw_items
		return unless raw_items

		raw_items.map do |item|
			time = self.parse_time item["startTime"]

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"is_private" => true,
				"original_id" => item["startTime"]
			}
		end
	end

	# ‘An unpublished app can make at most 2000 requests per hour and 60 requests
	# per minute.’
	def self.rate_limit ; @rate_limit ||= 1 * 1.25 end
end
