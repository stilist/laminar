namespace :withings do
	task :data do ; get_data end

	task :static_heart_local do
		items = preprocess_heart_data
		Laminar.put_static_data ENV["WITHINGS_HEART_FILENAME"], items
	end
	task :static_heart_remote do
		items = Laminar.get_static_data ENV["WITHINGS_STATIC_HEART_URL"]
		Laminar.add_items "withings", "heart", items
	end

	private

	def preprocess_heart_data
		require "csv"

		out = []

		CSV.foreach("sources/withings_heart.csv", headers: :first_row) do |row|
			time = Time.parse "#{row["DATE"]} #{row["HOUR"]}"
			original_id = "#{row["PSEUDO"]}-#{time.to_i}"

			out << {
				created_at: time.iso8601,
				updated_at: time.iso8601,
				original_id: original_id,
				data: {
					systolic: row["SYSTOL"].to_i,
					diastolic: row["DIASTOL"].to_i,
					pulse: row["PULSE"].to_i,
					comment: row["COMMENT"]
				}
			}
		end

		out
	end

	def get_data backfill=false
		client = LWithing.client
		items = client.get_all_data["body"]["measuregrps"]

		weight = items.select do |item|
			item["measures"].select { |measure| measure["type"] == 1 }.length > 0
		end
		non_weight = items - weight

		height = non_weight.select do |item|
			item["measures"].select { |measure| measure["type"] == 4 }.length > 0
		end

		heart = non_weight - height

		{ heart: heart, height: height, weight: weight }.each do |type, data|
			Laminar.add_items "withings", type, preprocess_data(data)
		end
	end

	def preprocess_data raw_items
		raw_items.map do |item|
			id = item["grpid"].to_s
			time = Time.at(item["date"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"original_id" => id
			}
		end
	end
end
