namespace :messages do
	task :static_desktop_local do
		items = LMessage.get_desktop_data
		Laminar.put_static_data ENV["MESSAGES_DESKTOP_FILENAME"], items
	end

	task :static_desktop_remote do
		items = Laminar.get_static_data ENV["MESSAGES_DESKTOP_URL"]
		Laminar.add_items "messages", "conversation", items
	end
end
