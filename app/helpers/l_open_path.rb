module LOpenPath
	def self.get_data backfill=false
		num_points = backfill ? 2000 : 100 # max: 2000

		# https://gist.github.com/pdarche/5034801
		base_url = "https://openpaths.cc/api/1"
		credentials = Crazylegs::Credentials.new ENV["OPENPATHS_CLIENT_KEY"], ENV["OPENPATHS_CLIENT_SECRET"]
		url = Crazylegs::SignedURL.new credentials, base_url, "GET"
		signed_url = url.full_url
		# http://stackoverflow.com/a/15821224/672403
		options = { num_points: num_points }
		res = HTTParty.get signed_url, query: options

		data = JSON.parse res.parsed_response
		items = LOpenPath.process_data data

		Laminar.add_items "openpaths", "location", items
	end

	def self.process_data raw_items
		raw_items.map do |item|
			id = item["t"].to_s
			time = Time.at(item["t"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"is_private" => true,
				"original_id" => id
			}
		end
	end
end
