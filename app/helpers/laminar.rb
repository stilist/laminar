module Laminar
	def item_classes data
		"hentry hnews type-#{data["activity_type"]} source-#{data["source"]}"
	end

	def item_hsl data
		date = data["created_at"]

		# TODO Start from 240
		hue = [360, date.yday].min

		# TODO
		conditions = {
			sunny: 100,
			partly_sunny: 80,
			partly_cloudy: 70,
			cloudy: 50,
			rain: 30,
			snow: 10
		}
		saturation = conditions[conditions.keys.sample]

		pct_of_day = (((date.hour * 60) + date.min) / 1400.0) * 100
		# Peak at midday
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor

		"background-color:hsl(#{hue}, #{saturation}%, #{luminance}%);"
	end
end
