module LLastfm
	def self.client ; Lastfm.new ENV["LASTFM_API_KEY"], ENV["LASTFM_API_SECRET"] end

	def self.get_data backfill=false
		client = self.client

		total = client.user.get_info(user: ENV["LASTFM_USER"])["playcount"].to_i
		per_page = 200 # max: 200
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts
		puts "*** #{total} tracks played"

		1.upto(pages).each_with_index do |page, p_idx|
			data = client.user.get_recent_tracks({
				limit: per_page,
				user: ENV["LASTFM_USER"],
				page: page,
				extended: 1
			})

			# Not sure why it doesn't always come through as an `Array`.
			data = [data] if data.is_a? Hash
			data.delete_at(0) if data.first["nowplaying"]
			items = self.process_data data

			Laminar.add_items "lastfm", "play", items

			# last.fm reports more items than can actually be pulled in; at some
			# point the script starts receiving the same data on every `page`.
			if backfill && items.length == per_page
				sleep 5
			else
				break
			end
		end
	end

	private

	def self.process_data raw_items
		raw_items.map do |item|
			time = DateTime.parse("#{item["date"]["content"]} GMT").to_time.iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"url" => item["url"],
				# Data doesn't have a reliable `id`, so hope the UNIX timestamp is
				# unique.
				"original_id" => item["date"]["uts"]
			}
		end
	end
end
