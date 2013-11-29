(($, window) -> $ ->
	kill_dygraph_event = (e) -> Dygraph.cancelEvent e

	defaults =
		axisLineColor: "#fff"
		colors: ["#fff"]
		drawXGrid: false
		drawYAxis: false
		drawYGrid: false
		height: 100
		highlightCircleSize: 0
		rollPeriod: 1
		showLabelsOnHighlight: false
		width: "100%"
		valueRange: [0, 1]
		interactionModel:
			"mousedown": kill_dygraph_event
			"mousemove": kill_dygraph_event
			"mouseup": kill_dygraph_event
			"click": kill_dygraph_event
			"dblclick": kill_dygraph_event
			"mousewheel": -> null

	window.graph = (options) ->
		element = options.selector.get 0
		delete options.selector

		data = options.data
		delete options.data

		settings = $.extend true, {}, defaults, options

		new Dygraph element, data, settings

)(window.$ or window.jQuery or window.Zepto, window)
