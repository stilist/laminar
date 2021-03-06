module Weather
	# stilist/laminar#1
	def self.prefetch start_date=nil, end_date=nil
		return [] unless start_date && end_date

		if start_date == end_date
			# Ideal would be start/end of day, but this is close enough.
			day = 60 * 60 * 24
			start_date = start_date - day
			end_date = start_date + day
		end

		start_date, end_date = end_date, start_date if start_date > end_date

		results = WeatherObservation.where("created_at >= ?", start_date).
				where("created_at <= ?", end_date).order("created_at ASC").all

		results = [Weather.nearest_observation(end_date, [])] if results.empty?

		results
	end

	def self.nearest_observation date=Time.now, prefetched=[]
		if !prefetched || prefetched.empty?
			above = WeatherObservation.where("created_at >= ?", date).first
			below = WeatherObservation.where("created_at <= ?", date).first
		# stilist/laminar#1
		else
			timestamps = prefetched.map { |d| d.created_at.to_i }
			date_i = date.to_i
			# http://www.ruby-forum.com/topic/129755#579143
			cut = timestamps.partition { |t| t < date_i }

			above = cut[1].empty? ? nil : prefetched[timestamps.index cut[1].max]
			below = cut[0].empty? ? nil : prefetched[timestamps.index cut[0].min]
		end

		above_dt = above ? (above["created_at"] - date) : nil
		below_dt = below ? (below["created_at"] - date) : nil

		if above_dt && below_dt
			(above_dt < below_dt) ? above : below
		else
			above || below || nil
		end
	end

	def self.icon_url icon, date=Time.now
		hour = date.strftime("%k").to_i
		icon = "nt_#{icon}" if hour < 7 || hour > 19

		"/assets/weather/#{icon}.gif"
	end
end
