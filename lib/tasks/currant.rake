namespace :currant do
	task :static_local do
		begin
			puts "-----> Currant: processing data"

			items = LCurrant.process_data "sources/currant"

			Laminar.put_static_data ENV["CURRANT_FILENAME"], items
		rescue => e
			puts "Currant processing failed:"
			puts e
		end
	end
	task :static_remote do
		items = Laminar.get_static_data ENV["CURRANT_URL"]
		Laminar.add_items "currant", "entry", items, { replace: true }
	end
end
