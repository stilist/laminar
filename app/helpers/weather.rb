module Weather
	def self.nearest_observation date=Time.now
		above = WeatherObservation.where("created_at >= ?", date).first
		above_dt = above["created_at"] - date
		below = WeatherObservation.where("created_at <= ?", date).first
		below_dt = below["created_at"] - date

		(above_dt < below_dt) ? above : below
	end
end
