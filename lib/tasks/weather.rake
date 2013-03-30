namespace :weather do
	task :backfill do
		if WeatherObservation.count > 0
			# Intentionally allow re-fetch of the last day--won't be re-inserted, but
			# may catch something missed the last time.
			end_date = WeatherObservation.reorder("created_at DESC").last.created_at.to_date
		else
			end_date = Date.today
		end
		start_date = end_date - 100

		get_weather_items start_date, end_date
	end

	task :yesterday do
		end_date = Date.today - 1
		start_date = end_date

		get_weather_items start_date, end_date
	end

	private

	def get_weather_items start_date=Date.today, end_date=Date.today
		key = ENV["WUNDERGROUND_API_KEY"]

		# TODO Make dynamic (currently Portland, OR)
		lat = 45.52
		lng = -122.681944
		location = "#{lat},#{lng}"

		puts
		if start_date == end_date
			puts "  * fetching weather for #{start_date}"
		else
			puts "  * fetching weather from #{start_date} to #{end_date}"
		end

		ActiveRecord::Base.record_timestamps = false
		(start_date..end_date).to_a.each do |date|
			_date = date.to_s.gsub "-", ""
			url = "http://api.wunderground.com/api/#{key}/history_#{_date}/q/#{location}.json"

			data = JSON.parse open(url).read
			observations = data["history"]["observations"]

			observations.each do |observation|
				d = observation["utcdate"]
				timestamp = DateTime.parse("#{d["year"]}-#{d["mon"]}-#{d["mday"]} #{d["hour"]}:#{d["min"]} UTC")

				existing = WeatherObservation.where(created_at: timestamp).count
				if existing == 0
					WeatherObservation.create({
						source: "wunderground",
						lat: lat,
						lng: lng,
						created_at: timestamp,
						updated_at: timestamp,
						data: observation
					})
				end
			end

			# Rate limit: 10 calls/minute
			sleep 10
		end
		ActiveRecord::Base.record_timestamps = true
	end
end
