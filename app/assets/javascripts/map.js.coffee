(($, window) -> $ ->
	$map = $("#map")
	bounds = geocoder = map = feature_layer = null
	mapbox_id = "stilist.h1i7n4a8"

	render_points = ->
		features = []

		locations = window.activity_points or []
		for location in locations
			features.push
				type: "Feature"
				geometry:
					type: "Point"
					coordinates: [location.lng, location.lat]
				properties:
					"marker-color": current_color
					"marker-size": "small"

		feature_layer.clearLayers()
		feature_layer.setGeoJSON
			type: "FeatureCollection"
			features: features

		bounds.extend feature_layer.getBounds()

	render_paths = ->
		points = window.activity_paths or []

		opts =
			color: "#333"
			opacity: 0.5
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

		render_points()
		render_paths()

		map.fitBounds bounds
	initialize() if $map.length > 0

)(window.$ or window.jQuery or window.Zepto, window)
