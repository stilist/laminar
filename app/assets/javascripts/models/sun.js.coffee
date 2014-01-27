(($, window) -> $ ->
	class window.Sun extends Backbone.Model
		defaults:
			# Portland, OR
			lat: 45.52
			lng: -122.67

		initialize: ->
			@on "change:timestamp", @_setPosition

		getDate: -> moment(@get "timestamp").tz("America/Los_Angeles").toDate()

		_setPosition: ->
			time = @getDate()
			[az, el] = time.getAzimuthAndElevation @get("lat"), @get("lng")

			@set "azimuth", az
			@set "elevation", el

)(window.$ or window.jQuery or window.Zepto, window)
