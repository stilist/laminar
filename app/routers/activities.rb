App.configure do |app|
	app.get "/activities/:id" do
		activities = Laminar.activities params, session
		@item = activities.find_by_id params[:id]

		@page_title = @item ? @item.title : 404
		@page_summary = @item ? @item.description : ""
		@page_type = :permalink
		@permalink = "/activities/#{params[:id]}"

		extras = { "full_view" => true }
		if @item
			@locations = @item.geolocations

			observations = Weather.prefetch @item.created_at, @item.created_at
			extras.merge!({ "observations" => observations })
		end

		page_out @item, ->{ 404 unless @item }, extras
	end

	app.get %r{/page/(\d+)} do
		if params[:page]
			redirect "/page/#{params[:page]}"
		else
			params[:page] = params[:captures][0]

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
end
