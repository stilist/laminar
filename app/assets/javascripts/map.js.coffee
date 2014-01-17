(($, window) -> $ ->
	$map = $("#map")
	map = null
	bounds = new google.maps.LatLngBounds

	render_points = ->
		points = []

		locations = window.activity_points or []
		for location in locations
			points.push
				name: "foo"
				latlng: new google.maps.LatLng location.lat, location.lng

		for point in points
			new google.maps.Marker
				position: point.latlng
				map: map
				title: point.name

			bounds.extend point.latlng

	render_paths = ->
		points = []

		paths = window.activity_paths or []
		points = paths.map (path) ->
			coords = new google.maps.LatLng path.lat, path.lng

			bounds.extend coords

			coords

		line = new google.maps.Polyline
			path: points
			geodesic: true
			strokeColor: "#333"
			strokeOpacity: 0.5
			strokeWeight: 2

		line.setMap map

	render_map = ->
		options =
			zoom: 13
			# center on Portland
			center: new google.maps.LatLng(45.5236, -122.6750)
			disableDefaultUI: true
			mapTypeId: google.maps.MapTypeId.ROADMAP

		map = new google.maps.Map $map.get(0), options

		render_points()
		render_paths()

		map.fitBounds bounds
	render_map() if $map.length > 0

)(window.$ or window.jQuery or window.Zepto, window)
