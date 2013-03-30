App.configure do |app|
	app.get "/" do
		@page_title = "Recent activity"
		@page_summary = @page_title
		@page_type = :index
		@permalink = "/"

		@items = Activity.page(params[:page]).all

		observations = Weather.prefetch @items.first.created_at, @items.last.created_at
		extras = { "observations" => observations }

		page_out @items, 200, extras
	end
end
