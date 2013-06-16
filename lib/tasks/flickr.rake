namespace :flickr do
	task :static_favorites do
		items = Laminar.get_static_data ENV["FLICKR_STATIC_FAVORITES_URL"]
		add_flickr_favorites items, "favorite"
	end

	task :static_photos do
		items = Laminar.get_static_data ENV["FLICKR_STATIC_PHOTOS_URL"]
		add_flickr_photos items, "photo"
	end

	private

	def add_flickr_favorites items, activity_type=""
		total = items.length

		puts
		puts "-----> #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "       #{item["id"]} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "flickr").
						where(activity_type: activity_type).
						where(original_id: item["id"]).count

				if existing == 0
					time = Time.at(item["date_faved"].to_i).iso8601

					Activity.create({
						source: "flickr",
						activity_type: activity_type,
						created_at: time,
						updated_at: time,
						data: item,
						original_id: item["id"]
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def add_flickr_photos items, activity_type=""
		total = items.length

		puts
		puts "-----> #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "       #{item["id"]} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "flickr").
						where(activity_type: activity_type).
						where(original_id: item["id"]).count

				if existing == 0
					Activity.create({
						source: "flickr",
						activity_type: activity_type,
						created_at: Time.parse(item["dates"]["taken"]).iso8601,
						updated_at: Time.at(item["dateuploaded"].to_i).iso8601,
						data: item,
						original_id: item["id"]
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
