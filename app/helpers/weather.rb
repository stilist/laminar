module Weather
	# TODO Don't make 2n queries
	def self.nearest_observation date=Time.now
		above = WeatherObservation.where("created_at >= ?", date).first
		above_dt = above ? (above["created_at"] - date) : nil

		below = WeatherObservation.where("created_at <= ?", date).first
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

		"http://icons.wxug.com/i/c/i/#{icon}.gif"
	end
end
