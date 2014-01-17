module LKiva
	def self.client
		@client ||= OAuth::Consumer.new ENV["KIVA_API_KEY"], ENV["KIVA_API_SECRET"], {
			access_token_path: "/oauth/access_token",
			authorize_url: "https://www.kiva.org/oauth/authorize",
			request_token_path: "/oauth/request_token",
			scheme: :header,
			site: "https://api.kivaws.org"
		}
	end

	def self.get_loans backfill=false
		total = self.get_data("/v1/my/loans")["paging"]["total"]
		per_page = 20 # max: 20
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "*** #{total} loans"

		1.upto(pages).each_with_index do |page, p_idx|
			raw_data = self.get_data "/v1/my/loans", { page: (p_idx + 1) }
			data = raw_data["loans"]
			items = self.process_data data

			Laminar.add_items "kiva", "loan", items, { replace: true }

			sleep self.rate_limit if p_idx < (pages - 1)
		end
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "loan"
			# hash breaks when serialized to the database
			activity["image"] = eval(activity["image"]) if activity["image"].is_a?(String)
			activity["video"] = eval(activity["video"]) if activity["video"].is_a?(String)
			activity["balance"] = eval(activity["balance"]) if activity["balance"].is_a?(String)
			activity["location"] = eval(activity["location"]) if activity["location"].is_a?(String)

			parsed[:image_url] = "http://s3.kiva.org/img/w800/#{activity["image"]["id"]}.jpg"
			parsed[:youtube_id] = activity["video"]["youtube_id"] if activity["video"]
			parsed[:title] = activity["name"]
			parsed[:description] = activity["use"]
			parsed[:amount] = activity["balance"]["total_amount_purchased"].to_s << ".00"
			parsed[:status] = activity["status"]
			parsed[:display_status] = parsed[:status].gsub /_/, " "

			location = activity["location"]
			parsed[:country] = location["country"]
			parsed[:town] = location["town"]
			parsed[:coords] = location["geo"]["pairs"].sub /\s+/, ","
		end

		parsed
	end

	private

	def self.access_token
		@token ||= OAuth::AccessToken.new self.client, ENV["KIVA_CLIENT_KEY"], ENV["KIVA_CLIENT_SECRET"]
	end

	def self.get_data url="", raw_params={}
		client = self.access_token

		params = raw_params.map { |k,v| "#{k}=#{v}" }.join "&"

		JSON.parse client.get("#{url}.json?#{params}").body
	end

	def self.get_balance loan_id
		self.get_data("/v1/my/loans/#{loan_id}/balances")["balances"].first
	end

	def self.process_data raw_items
		out = []

		raw_items.each do |item|
			data = item
			data["balance"] = self.get_balance item["id"]

			time = Time.at(data["balance"]["latest_share_purchase_time"]).getlocal.iso8601

			out << {
				"created_at" => time,
				"updated_at" => time,
				"data" => data,
				"url" => "http://www.kiva.org/lend/#{item["id"]}",
				"original_id" => item["id"].to_s
			}

			sleep self.rate_limit
		end

		out
	end

	def self.rate_limit ; @rate_limit ||= (500 / 60.0) * 1.25 end
end
