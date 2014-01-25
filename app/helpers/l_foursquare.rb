module LFoursquare
	def self.client
		abort "       Please specify FOURSQUARE_CLIENT_KEY" unless ENV["FOURSQUARE_CLIENT_KEY"]

		@client ||= Foursquare2::Client.new(oauth_token: ENV["FOURSQUARE_CLIENT_KEY"])
	end

	def self.authorize_client
		required_keys = %w(api_key api_secret)
		required_keys.each do |key|
			full = "FOURSQUARE_#{key.upcase}"
			abort "       Please specify #{full}" unless ENV[full]
		end

		@authorize_client ||= OAuth2::Client.new(ENV["FOURSQUARE_API_KEY"], ENV["FOURSQUARE_API_SECRET"],
			site: "http://foursquare.com/v2/",
			token_url: "/oauth2/access_token",
			authorize_url: "/oauth2/authenticate?response_type=code"
		)
	end

	def self.get_checkins backfill=false
		client = self.client

		_data = client.user_checkins limit: 1
		total = _data["count"].to_i
		per_page = 250 # max: 250
		pages = backfill ? (total / per_page.to_f).ceil : 1

		1.upto(pages).each_with_index do |page, p_idx|
			data = client.user_checkins limit: per_page, offset: (p_idx * per_page)
			items = self.process_data data.items

			Laminar.add_items "foursquare", "checkin", items, { replace: true }

			sleep self.rate_limit if p_idx < (pages - 1)
		end
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "checkin"
			if activity["createdBy"]
				user = activity["createdBy"]

				parsed[:checked_in_by] = {
					id: user["id"],
					first_name: user["firstName"],
					last_name: user["lastName"]
				}
			end

			parsed[:place_name] = activity["venue"]["name"]
		end

		parsed
	end

	def self.parse_locations data
		venue = eval data["venue"]

		{
			is_path: false,
			name: venue["name"],
			lat: venue["location"]["lat"],
			lng: venue["location"]["lng"],
			arrived_at: Time.at(data["createdAt"].to_i).getlocal.iso8601
		}
	end

	private

	def self.me ; self.client.user "self" end

	def self.process_data raw_items=[]
		me = self.me

		raw_items.map do |item|
			time = Time.at(item.createdAt).getlocal.iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item.to_hash,
				"url" => "//foursquare.com/user/#{me.id}/checkin/#{item.id}",
				"is_private" => (item.private || false),
				"original_id" => item.id.to_s
			}
		end
	end

	# ‘Authenticated requests can make 500 requests per hour per OAuth token to
	# the Foursquare API.’
	def self.rate_limit ; @rate_limit ||= ((60 * 60) / 500) * 1.25 end
end
