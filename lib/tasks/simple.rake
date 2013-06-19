namespace :simple do
	task :static_local do
		items = preprocess_simple_data
		Laminar.put_static_data ENV["SIMPLE_FILENAME"], items
	end

	task :static_remote do
		items = Laminar.get_static_data ENV["SIMPLE_URL"]
		Laminar.add_items "simple", "transaction", items
	end

	def preprocess_simple_data
		file = IO.read("sources/simple.json")
		data = JSON.parse file
		items = data["transactions"]

		items.map do |item|
			# TODO pull timezone from `item["geo"]` when possible
			time = Time.parse(item["times"]["when_recorded_local"]).iso8601

			{
				created_at: time,
				updated_at: time,
				original_id: item["uuid"],
				url: "http://simple.com/activity/transactions/#{item["uuid"]}",
				is_private: true,
				data: item
			}
		end
	end
end
