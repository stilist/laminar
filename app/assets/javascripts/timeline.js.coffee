(($, window) -> $ ->
	months = "January February March April May June July August September October November December".split " "
	data =
		projects: []
		tasks: []

	# Create some fake data
	for raw_dates, idx in timeline_dates
		[raw_start, raw_end] = raw_dates
		start_date = moment raw_start
		end_date = moment raw_end

		project =
			id: idx
			name: "DEMO"
			startDate: start_date
			endDate: end_date
			color: "rgba(255, 255, 255, 0.3)"
			tasks: []
		data.projects.push project

	if data.projects.length > 0
		sorted_start = _.sortBy data.projects, (project) ->
			project.startDate.unix()

		sorted_end = _.sortBy data.projects, (project) ->
			-project.startDate.unix()

		start_date = sorted_start[0].startDate
		end_date = sorted_end[0].endDate

		timespan = end_date.diff start_date, "days"
		duration = if timespan > 30 then "year"
		else if timespan > 7 then "month"
		else if timespan > 0 then "week"
		else
			visible_hours = Math.floor($(window).width() / 150)
			if end_date.diff(start_date, "hours") <= (visible_hours * 20)
				"hour"
			else
				"day"
	else
		start_date = null
		duration = "year"

	$("#timeline").gantt data,
		gridColor: "rgba(255, 255, 255, 0.3)"
		mode: "half"
		modes:
			half: { scale: 0.7, paddingX: 0, paddingY: 0.3, showContent: false }
		position: { date: start_date }
		showTasks: false
		view: duration

)(window.$ or window.jQuery or window.Zepto, window)
