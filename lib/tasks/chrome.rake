namespace :chrome do
	task :static_local do
		items = LChrome.get_data

		Laminar.put_static_data ENV["CHROME_FILENAME"], items
	end

	task :static_remote do
		items = Laminar.get_static_data ENV["CHROME_URL"]
		Laminar.add_items "chrome", "history", items
	end
end
