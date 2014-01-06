(($, window) -> $ ->
	$form = $("#login form")
	$fields = $form.find ".field input"
	$submit = $("input.btn")

	_always = (xhr, status) -> $submit.removeClass "active"

	_can_submit = -> _get_empty_fields().length is 0 and !$submit.hasClass "active"

	_done = (response, status, xhr) -> window.location.href = "/"

	_fail = (xhr, status, error) -> $fields.first().trigger "focus"

	_get_empty_fields = -> _.compact($fields.map -> @ if $(@).val() is "")

	_submit = (e) ->
		e.preventDefault()

		if _can_submit()
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
		else
			$fields.first().trigger "focus"

	$submit.on "click", _submit

)(window.$ or window.jQuery or window.Zepto, window)
