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

	def h(text="") ; Rack::Utils.escape_html(text) end

	def nl2br(text) ; text.gsub(/[\n|\r]/, "<br>") end

	def item_classes data, extra_classes=[]
		classes = %w(hentry hnews) << extra_classes.join(" ")
		classes << "type-#{data["activity_type"]} source-#{data["source"]}"
		classes << "full_view" if data["extras"]["full_view"]
		classes.join " "
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
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor.abs

		{ hue: hue, saturation: saturation, luminance: luminance }
	end
end
