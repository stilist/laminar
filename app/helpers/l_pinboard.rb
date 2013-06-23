module LPinboard
	def self.get_data backfill=false
		client = Pinboard::Client.new(username: ENV["PINBOARD_USER"],
				password: ENV["PINBOARD_PASSWORD"])

		data = backfill ? client.posts : client.posts(results: 100)
		items = self.process_data data

		Laminar.add_items "pinboard", "bookmark", items
	end

	def self.process_data raw_items=[]
		raw_items.map do |item|
			{
				"created_at" => item.time,
				"updated_at" => item.time,
				"is_private" => !item.shared.nil?,
				"url" => item.href,
				"original_id" => item.href,
				"data" => self.construct_pinboard_data(item)
			}
		end
	end

	def self.construct_pinboard_data item
		keys = %w(href description extended tag time replace shared toread)
		out = {}
		keys.each { |k| out[k] = item.send k.to_sym }

		out
	end
end
