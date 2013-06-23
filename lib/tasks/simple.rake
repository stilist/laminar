namespace :simple do
	task :static_local do
		items = LSimple.preprocess_data
		Laminar.put_static_data ENV["SIMPLE_FILENAME"], items
	end

	task :static_remote do
		items = Laminar.get_static_data ENV["SIMPLE_URL"]
		Laminar.add_items "simple", "transaction", items
	end
end
