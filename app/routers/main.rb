App.configure do |app|
	app.get "/" do
		items = app.collection.find().limit(100).to_a
		data = items.empty? ? {} : items
		page_out data
	end

	app.get "/node/:hash_key" do |page|
		item = app.collection.find(_id: BSON::ObjectId(params[:hash_key])).first
		page_out item, ->{ 404 unless item }
	end
end
