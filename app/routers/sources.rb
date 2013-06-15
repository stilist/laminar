App.configure do |app|
	app.get "/sources/:name" do
		@page_type = :index

		activities = Laminar.activities params
		@items = activities.where(source: params[:name]).all

		if !@items.empty?
			@permalink = "/sources/#{params[:name]}"

			@page_title = "Activity from #{params[:name]}"
			# TODO Something better
			@page_summary = @page_title

			observations = Weather.prefetch @items.first.created_at, @items.last.created_at
			extras = { "observations" => observations }
		else
			extras = {}
		end

		extras["private_data_key"] = params[:private_data_key]
		page_out @items, ->{ 404 unless @items }, extras
	end
end
