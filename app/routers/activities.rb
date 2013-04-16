App.configure do |app|
	app.get "/activities/:id" do
		item = Activity.find_by_id params[:id]

		@page_title = item ? item.title : 404
		@page_summary = item ? item.description : ""
		@page_type = :permalink
		@permalink = "/activities/#{params[:id]}"

		extras = { "full_view" => true }
		if item
			observations = Weather.prefetch item.created_at, item.created_at
			extras.merge!({ "observations" => observations })
		end

		page_out item, ->{ 404 unless item }, extras
	end
end
