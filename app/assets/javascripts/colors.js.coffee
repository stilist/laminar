(($, window) -> $ ->
	hour = 60
	day = hour * 24

	conditions = {
		sunny: 0.8,
		mostlysunny: 0.73,
		partlysunny: 0.7,
		clear: 0.63,
		partlycloudy: 0.6,
		mostlycloudy: 0.55,
		cloudy: 0.5,
		fog: 0.45,
		hazy: 0.4,
		rain: 0.4,
		tstorms: 0.37,
		chancetstorms: 0.35,
		chancerain: 0.3,
		chanceflurries: 0.2,
		chancesnow: 0.17,
		flurries: 0.15,
		snow: 0.1,
		chancesleet: 0.1,
		sleet: 0.07,
		unknown: 0
	}

	window.get_color = (timestamp, condition, as_hex=true) ->
		m = moment timestamp

		# TODO use CIELAB
		doy = m.dayOfYear()
		hue = Math.min(360, doy) + 240
		hue = hue - 360 if hue > 360

		# minutes...   [       through day       ]   [in day]   [%]
		pct_of_day = (((m.hour() * hour) + m.minute()) / day) * 100
		# TODO use actual sunrise/sunset
		luminance = if (pct_of_day > 50) then (100 - pct_of_day) else pct_of_day
		luminance = luminance / 100

		saturation = if condition then conditions[condition] else 1

		color = chroma.hsl hue, saturation, (luminance + 0.2)
		if as_hex then color.hex() else color

	set_chrome_colors = ->
		window.current_color = get_color()

		$("#nameplate").css borderTopColor: current_color
		$("#login input[type=submit]").css backgroundColor: current_color
	setInterval set_chrome_colors, (60 * 1000)
	set_chrome_colors()

	$(".hentry").each ->
		$entry = $(@)

		timestamp = $entry.find(".updated").attr "datetime"

		weather = $entry.prop("class").match(/weather-(\w+)/)
		condition = weather[1] if weather

		bg_color = color = get_color timestamp, condition, false

		# For the upper and lower third it's enough to use the inverse. For the
		# remaining third there's not enough contrast, so cheat a bit.
		counter_lum = 1 - bg_color.luminance()
		if counter_lum in [0.5..0.66]
			counter_lum += 0.25
		else if counter_lum in [0.33..0.5]
			counter_lum -= 0.25
		bg_hsl = bg_color.hsl()
		color = chroma.hsl bg_hsl[0], bg_hsl[1], counter_lum

		$entry.css
			backgroundColor: bg_color.hex()
			color: color.hex()

)(window.$ or window.jQuery or window.Zepto, window)
