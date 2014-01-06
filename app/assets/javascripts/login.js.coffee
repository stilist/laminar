(($, window) -> $ ->
	$form = $("#login form")
	$username = $(".handle input")
	$password = $(".password input")
	$submit = $("input.btn")

	_done = (response, status, xhr) -> window.location.pathname = "/"
	_fail = (xhr, status, error) -> $username.trigger "focus"
	_always = (xhr, status) -> $submit.removeClass "active"

	_submit = (e) ->
		e.preventDefault()

		$submit.addClass "active"

		$.ajax
			cache: false
			complete: _always
			data: $form.toObject()
			dataType: "json"
			error: _fail
			success: _done
			type: "POST"
			url: $form.prop "action"

	$submit.on "click", _submit

)(window.$ or window.jQuery or window.Zepto, window)
