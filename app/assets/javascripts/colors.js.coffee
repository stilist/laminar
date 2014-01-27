(($, window) -> $ ->
	model = new Sun
	model.set "timestamp", new Date()
	$sun = $("#nameplate .sun")

	positionSun = ->
		azimuth = model.get "azimuth"
		elevation = model.get "elevation"

		if azimuth and elevation
			azimuth_pct = (azimuth / 360) * 100
			elevation_pct = 100 * ((-elevation / 180) * 2) + 50

			position =
				left: "#{azimuth_pct}%"
				top: "#{elevation_pct}%"

			$sun.css position

	set_chrome_colors = ->
		window.current_color = get_color model.getDate()

		$("#nameplate").css borderTopColor: current_color
		$("#login input[type=submit]").css backgroundColor: current_color

	setInterval ->
		# ###
		ts = model.get "timestamp"
		new_ts = moment(ts).add "hour", 1
		model.set "timestamp", new_ts
		# ###
		# model.set "timestamp", new Date()

		positionSun()
		set_chrome_colors()
	, 250
	# , (60 * 1000)

	positionSun()
	set_chrome_colors()

)(window.$ or window.jQuery or window.Zepto, window)
