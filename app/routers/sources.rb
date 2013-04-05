App.configure do |app|
	app.get "/sources/:name" do
		@page_type = :index
		@items = Activity.where(source: params[:name]).page(params[:page]).all

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

		page_out @items, ->{ 404 unless @items }, extras
	end
end
