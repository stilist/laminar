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

	def markdown text=""
		markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML, autolink: true

		# Hack: Redcarpet specifically refuses to process Markdown inside of
		# `<figure>` tags, though absolutely any other tag seems to be fine.
		temp_text = text.gsub(/<(\/?figure)>/, "<\\1_temp>")
		out = markdown.render temp_text
		out.gsub /_temp>/, ">"
	end

	def h(text="") ; Rack::Utils.escape_html(text) end

	def nl2br(text) ; text.gsub(/(\r\n|\r|\n)/, "<br>") end

	def item_classes data
		classes = %w(hentry hnews)
		classes << "type-#{data["activity_type"]} source-#{data["source"]}"
		classes << "full_view" if data["extras"]["full_view"]
		classes << "hreview" if data["activity_type"] == "review"
		classes.join " "
	end

	def item_hsl data, as_style=true
		observations = data["extras"] ? data["extras"]["observations"] : nil

		hsl = calculate_hsl data, observations

		if as_style
			lum = hsl[:luminance]
			# For the upper and lower third it's enough to use the inverse. For the
			# remaining third there's not enough contrast, so cheat a bit.
			counter_lum = 100 - lum
			if (33..66).include? counter_lum
				counter_lum = (counter_lum > 50) ? (counter_lum + 25) : (counter_lum - 25)
			end

			"background-color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{lum}%);
			color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{counter_lum}%);"
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
