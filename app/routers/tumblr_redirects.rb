App.configure do |app|
	app.get "/post/*" do
		path = params[:splat][0]

		activity = Activity.where(source: "tumblr").where(activity_type: "post").
				where(url: "http://ratafia.info/post/#{path}").first

		if activity
			redirect "/activities/#{activity.id}", 301
		else
			status 404
			haml "Page not found."
		end
	end

	app.get "/day/*/" do
		date = params[:splat][0]

		redirect "/0#{date}", 301
	end

	# `/archive/2013/3`
	app.get "/archive/*" do
		date = params[:splat][0].split "/"
		year = date[0]
		month = date[1]
		month = "0#{month}" if month.length == 1

		redirect "/0#{year}/#{month}", 301
	end

	app.get "/archive" do
		redirect "/", 301
	end
end
