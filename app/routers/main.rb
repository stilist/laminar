App.configure do |app|
	app.get "/" do
		@page_type = :index
		@permalink = "/"

		@items = Activity.page(params[:page]).all

		observations = Weather.prefetch @items.first.created_at, @items.last.created_at
		extras = {
			"full_view" => false,
			"observations" => observations
		}

		page_out @items, 200, extras
	end
end
