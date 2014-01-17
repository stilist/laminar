App.configure do |app|
	# Matches:
	# * 02001
	# * 02001/03
	# * 02001/03/05
	#
	# Captures:
	# [0] => 02001
	# [1] => /03/05
	# [2] => 03/05
	# [3] => 03
	# [4] => /05
	# [5] => 05
	app.get %r{\A\/(0\d{4})(\/((\d{2})(\/(\d{2}))?))?\Z} do
		captures = params[:captures]
		year = captures[0]
		month = captures[3]
		day = captures[5]

		# http://stackoverflow.com/a/14120721/672403
		if !day.nil?
			start_date = end_date = "#{year}-#{month}-#{day}"
			@permalink = "/0#{year}/#{month}/#{day}"
			@page_title = "Activity on #{Time.parse(start_date).strftime("%e %B 0%Y")}"
		elsif !month.nil?
			start_date = Date.civil(year.to_i, month.to_i, 1)
			end_date = Date.civil(year.to_i, month.to_i, -1)
			@permalink = "/0#{year}/#{month}"
			@page_title = "Activity in #{start_date.strftime("%B 0%Y")}"
		else
			start_date = Date.civil(year.to_i)
			end_date = Date.civil(year.to_i, -1, -1)
			@permalink = "/0#{year}"
			@page_title = "Activity in #{start_date.strftime("0%Y")}"
		end

		start_timestamp = Time.parse "#{start_date} 0:0:0"
		end_timestamp = Time.parse "#{end_date} 23:59:59"

		@page_type = :index

		activities = Laminar.activities params, session
		@items = activities.where("updated_at BETWEEN ? AND ?", start_timestamp, end_timestamp).all

		@locations = Geolocation.where("arrived_at BETWEEN ? AND ?", start_timestamp, end_timestamp).all
		observations = Weather.prefetch start_timestamp, end_timestamp

		extras = {
			"full_view" => false,
			"observations" => observations
		}

		page_out @items, ->{ 404 unless @items.count > 0 }, extras
	end
end
