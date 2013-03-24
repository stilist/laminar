App.configure do |app|
	app.get "/" do
		@page_title = "Recent activity"
		@page_summary = @page_title
		@page_type = :index
		@permalink = "/"

		items = Activity.limit(50).all
		page_out items
	end
end
