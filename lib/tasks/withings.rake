namespace :withings do
	task :data do ; LWithing.get_data end

	task :static_heart_local do
		items = LWithing.preprocess_heart_data
		Laminar.put_static_data ENV["WITHINGS_HEART_FILENAME"], items
	end
	task :static_heart_remote do
		items = Laminar.get_static_data ENV["WITHINGS_STATIC_HEART_URL"]
		Laminar.add_items "withings", "heart", items
	end
end
