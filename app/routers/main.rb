App.configure do |app|
	app.get "/" do
		@page_type = :index
		@permalink = "/"

		activities = Laminar.activities params, session
		@items = activities.all

		extras = { "full_view" => false }
		unless @items.empty?
			start_timestamp = @items.last.created_at
			end_timestamp = @items.first.created_at

			@locations = Laminar.locations start_timestamp, end_timestamp, session
			observations = Weather.prefetch start_timestamp, end_timestamp

			extras.merge!({ "observations" => observations })
		end

		page_out @items, 200, extras
	end
end
