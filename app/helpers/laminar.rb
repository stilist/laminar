module Laminar
	def item_classes data
		hsl = calculate_hsl data
		luminance = case
			when hsl[:luminance] > 65 then "light"
			when hsl[:luminance] < 45 then "dark"
			else "mid"
		end

		"hentry hnews type-#{data["activity_type"]} source-#{data["source"]} #{luminance}"
	end

	def item_hsl data
		hsl = calculate_hsl data
		"background-color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{hsl[:luminance]}%);"
	end

	private

	def calculate_hsl data
		date = data["created_at"]

		# TODO Start from 240
		hue = [360, date.yday].min

		# TODO
		saturation = data["data"]["id"][-2..-1].to_i

		pct_of_day = (((date.hour * 60) + date.min) / 1400.0) * 100
		# Peak at midday
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor

		{ hue: hue, saturation: saturation, luminance: luminance }
	end
end
