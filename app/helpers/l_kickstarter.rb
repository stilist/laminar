module LKickstarter
	def self.client
		abort "       Please specify KICKSTARTER_USER" unless ENV["KICKSTARTER_USER"]
		abort "       Please specify KICKSTARTER_PASSWORD" unless ENV["KICKSTARTER_PASSWORD"]

		Kickscraper.configure do |config|
			config.email = ENV["KICKSTARTER_USER"]
			config.password = ENV["KICKSTARTER_PASSWORD"]
		end

		@client ||= Kickscraper.client
	end

	def self.get_backed backfill=false
		data = self.client.user.backed_projects
		items = self.process_data data

		Laminar.add_items "kickstarter", "backed", items, { replace: true }
	end

	private

	def self.process_data raw_items
		raw_items.map do |raw_item|
			item = raw_item.to_hash
			item["category"] = raw_item.category.to_hash
			item["creator"] = raw_item.creator.to_hash

			time = Time.at(item["state_changed_at"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"url" => item["urls"]["web"]["project"],
				"original_id" => item["id"].to_s
			}
		end
	end
end
