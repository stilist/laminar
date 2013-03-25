module Laminar
	@@conditions = {
		sunny: 80,
		mostlysunny: 73,
		partlysunny: 70,
		clear: 63,
		partlycloudy: 60,
		mostlycloudy: 55,
		cloudy: 50,
		fog: 45,
		hazy: 40,
		rain: 40,
		tstorms: 37,
		chancetstorms: 35,
		chancerain: 30,
		chanceflurries: 20,
		chancesnow: 17,
		flurries: 15,
		snow: 10,
		sleet: 7,
		chancesleet: 10,
		unknown: 0
	}.freeze

	def item_classes data
		hsl = calculate_hsl data
		lower = 50
		upper = 65

		avg = (hsl[:saturation] + hsl[:luminance]) / 2

		brightness = if avg < lower || hsl[:saturation] < lower || hsl[:luminance] < lower
			"dark"
		elsif avg >= upper
			"light"
		else
			"mid"
		end

		"hentry hnews type-#{data["activity_type"]} source-#{data["source"]} #{brightness}"
	end

	def item_hsl data
		hsl = calculate_hsl data
		"background-color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{hsl[:luminance]}%);"
	end

	private

	def calculate_hsl data
		date = data["created_at"]

		# TODO Start from 240
		hue = [360, date.yday].min + 240
		hue = (hue > 360) ? (hue - 360) : hue

		wo = Weather::nearest_observation data["created_at"]
		saturation = @@conditions[wo["data"]["icon"].to_sym] || 0

		pct_of_day = (((date.hour * 60) + date.min) / 1400.0) * 100
		# Peak at midday
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor

		{ hue: hue, saturation: saturation, luminance: luminance }
	end
end
