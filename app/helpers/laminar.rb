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
		observations = data["extras"] ? data["extras"]["observations"] : nil

		hsl = calculate_hsl data, observations
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

		"hentry hnews type-#{data["activity_type"]} source-#{data["source"]} #{brightness} #{extra_classes.join(" ")}"
	end

	def item_hsl data, as_style=true
		observations = data["extras"] ? data["extras"]["observations"] : nil

		hsl = calculate_hsl data, observations

		if as_style
			"background-color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{hsl[:luminance]}%);"
		else
			[hsl[:hue], (hsl[:saturation] / 100.0), (hsl[:luminance] / 100.0)]
		end
	end

	def self.sym2s h
		# http://stackoverflow.com/a/8380073/672403
		Hash === h ? Hash[h.map { |k, v| [k.to_s, Laminar.sym2s(v)] }] : h
	end

	private

	def calculate_hsl data, observations=nil
		date = data["created_at"]

		hue = [360, date.yday].min + 240
		hue = (hue > 360) ? (hue - 360) : hue

		wo = Weather::nearest_observation data["created_at"], observations
		saturation = wo ? (@@conditions[wo["data"]["icon"].to_sym] || 0) : 0

		# minutes...   [       through day       ]   [in day]
		pct_of_day = (((date.hour * 60) + date.min) / 1400.0) * 100
		# Peak at midday
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor

		{ hue: hue, saturation: saturation, luminance: luminance }
	end
end
