App.configure do |app|
	app.get "/" do
		items = Entity.all
		data = items.empty? ? {} : items
		page_out data
	end

	app.get "/node/:hash_key" do |page|
		item = Entity.find_by_hash_key params[:hash_key]
		page_out item, ->{ 404 unless item }
	end
end
