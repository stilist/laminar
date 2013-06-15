namespace :withings do
	task :data do ; get_withings_data end

	private

	def get_withings_data backfill=false
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

		add_withings_items heart, "heart"
		add_withings_items height, "height"
		add_withings_items weight, "weight"
	end

	def add_withings_items items, activity_type
		total = items.length

		puts
		puts "-----> Withings: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				id = item["grpid"].to_s

				puts "       #{activity_type}: #{id} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "withings").
						where(activity_type: activity_type).
						where(original_id: id).count

				if existing == 0
					time = Time.at(item["date"]).iso8601

					Activity.create({
						source: "withings",
						activity_type: activity_type,
						created_at: time,
						updated_at: time,
						data: item,
						original_id: id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
