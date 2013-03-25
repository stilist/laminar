module Weather
	def self.nearest_observation date=Time.now
		above = WeatherObservation.where("created_at >= ?", date).first
		above_dt = above["created_at"] - date
		below = WeatherObservation.where("created_at <= ?", date).first
		below_dt = below["created_at"] - date

		(above_dt < below_dt) ? above : below
	end

	def self.icon_url icon, date=Time.now
		hour = date.strftime("%k").to_i
		icon = "nt_#{icon}" if hour < 7 || hour > 19

		"http://icons.wxug.com/i/c/i/#{icon}.gif"
	end
end
