App.configure do |app|
	app.get "/locations" do
		@page_type = :index
		@permalink = "/locations"

		@locations = session[:login] ? Geolocation.all : []

		page_out [], 200, {}
	end
end
