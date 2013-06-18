(($, window) -> $ ->
	$map = $("#map")
	map = null

	render_markers = ->
		locations = window.activity_locations or []
		points = []
		for location in locations
			points.push
				name: "foo"
				latlng: new google.maps.LatLng(location.lat, location.lng)

		bounds = new google.maps.LatLngBounds
		for point in points
			new google.maps.Marker
				position: point.latlng
				map: map
				title: point.name

			bounds.extend point.latlng

		map.fitBounds bounds

	render_map = ->
		options =
			zoom: 13
			# center on Portland
			center: new google.maps.LatLng(45.5236, -122.6750)
			disableDefaultUI: true
			mapTypeId: google.maps.MapTypeId.ROADMAP

		map = new google.maps.Map $map.get(0), options

		render_markers()
	render_map() if $map.length > 0

)(window.$ or window.jQuery or window.Zepto, window)
