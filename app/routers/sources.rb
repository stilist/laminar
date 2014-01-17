App.configure do |app|
	app.get "/sources/:name" do
		@page_type = :index

		activities = Laminar.activities params, session
		@items = activities.where(source: params[:name]).all
		@source = params[:name]

		if !@items.empty?
			@permalink = "/sources/#{params[:name]}"

			@page_title = "Activity from #{params[:name]}"
			# TODO Something better
			@page_summary = @page_title

			start_timestamp = @items.last.created_at
			end_timestamp = @items.first.created_at

			@locations = Laminar.locations start_timestamp, end_timestamp, session
			observations = Weather.prefetch start_timestamp, end_timestamp

			extras = { "observations" => observations }
		else
			extras = {}
		end

		page_out @items, ->{ 404 unless @items }, extras
	end
end
