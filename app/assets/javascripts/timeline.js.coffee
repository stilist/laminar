(($, window) -> $ ->
	months = "January February March April May June July August September October November December".split " "
	data =
		projects: []
		tasks: []

	# Create some fake data
	for raw_date, idx in timeline_dates
		start_date = moment raw_date

		# TEMP
		offset = Math.ceil(Math.random() * 480) # 8 hours
		end_date = start_date.clone().add "minutes", offset

		project =
			id: idx
			name: "DEMO"
			startDate: start_date
			endDate: end_date
			color: "blue"
			tasks: []
		data.projects.push project

	if data.projects.length > 0
		sorted = _.sortBy data.projects, (project) ->
			project.startDate.unix()

		start_date = sorted[0].startDate.subtract "hours", 10
	else
		start_date = null

	$("#timeline").gantt data,
		mode: "half"
		modes:
			half: { scale: 1, paddingX: 0, paddingY: 0, showContent: false }
		position: { date: start_date }
		view: "year"

)(window.$ or window.jQuery or window.Zepto, window)
