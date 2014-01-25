(($, window) -> $ ->
	$map = $("#map")
	$toggle = $("#map-size-toggle")
	bounds = geocoder = map = feature_layer = null
	mapbox_id = "stilist.h1i7n4a8"

	resize_map = (e) ->
		e.preventDefault()

		is_open = $toggle.hasClass "open"
		height = if is_open then 300 else 500

		$toggle.toggleClass "open", !is_open

		$map.animate { height: height },
			complete: -> map.invalidateSize()

	initialize_toggle = ->
		$toggle.show().css
			top: $map.offset().top + 10

		$toggle.on "click", resize_map

	render_points = ->
		locations = window.activity_points or []
		return if locations.length is 0

		features = []

		for location in locations
			features.push
				type: "Feature"
				geometry:
					type: "Point"
					coordinates: [location.lng, location.lat]
				properties:
					"title": location.name
					"marker-color": current_color
					"marker-size": "small"

		feature_layer.clearLayers()
		feature_layer.setGeoJSON
			type: "FeatureCollection"
			features: features

		bounds.extend feature_layer.getBounds()

	render_paths = ->
		points = window.activity_paths or []
		return if points.length is 0

		opts =
			color: "#333"
			opacity: 0.5
			smoothFactor: 2
			weight: 1
		line = L.polyline(points, opts).addTo map

		bounds.extend line.getBounds()

	initialize = ->
		geocoder = L.mapbox.geocoder mapbox_id
		map = L.mapbox.map "map", mapbox_id,
			tileLayer: { detectRetina: true }
		feature_layer = L.mapbox.featureLayer().addTo map

		geocoder.query "Portland, OR", render_map

	render_map = (err, data) ->
		bounds = data.lbounds

		initialize_toggle()
		render_points()
		render_paths()

		# without the `setTimeout` the map will often render partway and become
		# non-responsive
		setTimeout -> map.fitBounds bounds
	initialize() if $map.length > 0

)(window.$ or window.jQuery or window.Zepto, window)
