module LInstagram
	def self.get_data activity_type, max_id=nil
		delay = (60 * 60) / 5000 # max 5000 requests per user/client per hour

		options = { access_token: ENV["INSTAGRAM_CLIENT_KEY"] }

		existing = Activity.where(activity_type: activity_type).
				where(source: "instagram")

		if max_id
			if max_id.is_a?(String) && activity_type == "like"
				options.merge!({ max_like_id: max_id })
			elsif activity_type == "photo"
				oldest = existing.last
				options.merge!({ max_id: oldest["data"]["id"].split("_")[0] }) if oldest
			end
		elsif activity_type == "photo"
			newest = existing.first
			options.merge!({ min_id: newest["data"]["id"] }) if newest
		end

		method = case activity_type
		when "like" then :user_liked_media
		when "photo" then :user_recent_media
		end
		data = Instagram.send method, options
		items = self.process_data data

		Laminar.add_items "instagram", activity_type, items

		if !items.empty? and max_id
			sleep delay

			next_max_id = case activity_type
			when "like" then data.pagination.next_max_like_id
			when "photo" then data.pagination.next_max_id
			end

			self.get_data activity_type, next_max_id
		end
	end

	def self.parse_locations data, activity_type
		if activity_type == "photo"
			location = data["location"] ? eval(data["location"]) : nil

			if location
				{
					is_path: false,
					name: location["name"],
					lat: location["latitude"],
					lng: location["longitude"]
				}
			end
		end
	end

	private

	def self.process_data raw_items
		raw_items.map do |item|
			time = Time.at(item["created_time"].to_i).iso8601

			data = {}
			# Without this the `Hashie::Mash` values are effectively serialized
			# as `v.inspect`, and are unusable.
			item.each { |k,v| data[k] = v.is_a?(Hashie::Mash) ? v.to_hash : v }

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => data,
				"url" => item["link"],
				"original_id" => item.id
			}
		end
	end
end
