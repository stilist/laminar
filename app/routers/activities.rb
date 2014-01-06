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
			observations = Weather.prefetch @item.created_at, @item.created_at
			extras.merge!({ "observations" => observations })
		end

		extras["private_data_key"] = params[:private_data_key]
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
				observations = Weather.prefetch @items.first.created_at, @items.last.created_at
				extras.merge!({ "observations" => observations })
			end

			extras["private_data_key"] = params[:private_data_key]
			page_out @items, 200, extras
		end
	end
end
