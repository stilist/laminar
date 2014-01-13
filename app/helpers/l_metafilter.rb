module LMetafilter
	def self.get_favorite_posts
		url = "http://www.metafilter.com/xml/user-favorites.cfm?user_id=#{ENV["METAFILTER_USER_ID"]}"

		data = Laminar.fetch_feed url
		items = self.process_data data

		Laminar.add_items "metafilter", "favorite", items
	end

	def self.parse_activity activity, activity_type
		Laminar.s2sym activity["data"]
	end

	private

	def self.process_data raw_items
		raw_items.map do |item|
			time = item.pubDate.iso8601

			data = {
				"title" => item.title.sub("MeFi: ", ""),
				"description" => item.description
			}

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => data,
				"url" => item.link,
				"original_id" => item.guid.content
			}
		end
	end
end
