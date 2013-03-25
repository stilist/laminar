App.configure do |app|
	app.get "/activities/:id" do
		@page_summary = @page_title
		@page_type = :permalink
		@permalink = "/activities/#{params[:id]}"

		item = Activity.find_by_id params[:id]
		@page_title = item ? "#{item["source"]} #{item["activity_type"]}" : 404
		page_out item, ->{ 404 unless item }
	end
end
