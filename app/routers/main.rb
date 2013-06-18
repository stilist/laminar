App.configure do |app|
	app.get "/" do
		@page_type = :index
		@permalink = "/"

		activities = Laminar.activities params
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
