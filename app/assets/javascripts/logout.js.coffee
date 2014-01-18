(($, window) -> $ ->
	$logout = $("#nameplate #logout")

	_always = (xhr, status) -> $logout.removeClass "active"

	_done = (response, status, xhr) -> window.location.href = "/"

	_log_out = (e) ->
		e.preventDefault()

		unless $logout.hasClass "active"
			$logout.addClass "active"

			$.ajax
				cache: false
				complete: _always
				dataType: "json"
				success: _done
				type: "POST"
				url: "/logout"

	$logout.on "click", _log_out

)(window.$ or window.jQuery or window.Zepto, window)
