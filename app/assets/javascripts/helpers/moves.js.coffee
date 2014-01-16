(($, window) -> $ ->
	$items = $(".source-moves .move")
	$items.each ->
		$item = $(@)

		$item.children().remove()

		start = moment($item.data "start")
		end = moment($item.data "end")

		distance = start.from end, true

		$item.append "<span>(#{distance})</span>"

)(window.$ or window.jQuery or window.Zepto, window)
