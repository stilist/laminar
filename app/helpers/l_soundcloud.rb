module LSoundcloud
	def self.client
		abort "       Please specify SOUNDCLOUD_CLIENT_KEY" unless ENV["SOUNDCLOUD_CLIENT_KEY"]

		@client ||= Soundcloud.new(access_token: ENV["SOUNDCLOUD_CLIENT_KEY"])
	end

	def self.authorize_client
		required_keys = %w(api_secret api_key authorize_url)
		required_keys.each do |key|
			full = "SOUNDCLOUD_#{key.upcase}"
			abort "       Please specify #{full}" unless ENV[full]
		end

		@auth_client ||= Soundcloud.new(
			client_id: ENV["SOUNDCLOUD_API_KEY"],
			client_secret: ENV["SOUNDCLOUD_API_SECRET"],
			redirect_uri: ENV["SOUNDCLOUD_AUTHORIZE_URL"]
		)
	end

	def self.get_favorites backfill=false
		client = self.client
		me = client.get "/me"

		data = self.client.get "/users/#{me["id"]}/favorites"
		items = self.process_data data

		Laminar.add_items "soundcloud", "favorite", items
	end

	def self.get_tracks backfill=false
		client = self.client
		me = client.get "/me"

		data = self.client.get "/users/#{me["id"]}/tracks"
		items = self.process_data data

		Laminar.add_items "soundcloud", "track", items
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "favorite"
			parsed[:title] = activity["title"]
			parsed[:description] = activity["description"]
			parsed[:user_name] = activity["user"]["username"]
			parsed[:user_url] = activity["user"]["permalink_url"]
		when "track"
			parsed[:title] = activity["title"]
			parsed[:description] = activity["description"]
		end

		parsed
	end

	# In theory this has the same output as soundcloud-ruby’s `.exchange_token`,
	# except that this works, instead of getting `invalid_client`.
	def self.get_access_token code=""
		url = "https://api.soundcloud.com/oauth2/token"

		raw_params = {
			client_id: ENV["SOUNDCLOUD_API_KEY"],
			client_secret: ENV["SOUNDCLOUD_API_SECRET"],
			code: code,
			grant_type: "authorization_code",
			redirect_uri: ENV["SOUNDCLOUD_AUTHORIZE_URL"]
		}
		params = raw_params.map { |k,v| Curl::PostField.content k.to_s, v }

		req = Curl::Easy.new url
		req.multipart_form_post = true
		req.http_post *params

		JSON.parse(req.body_str)["access_token"]
	end

	def self.embed id, hsl
		color = hsl ? ColorMath::HSL.new(*hsl).hex[1..-1] : "ff6600"

		%Q{<iframe width="100%" height="166" scrolling="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/#{id}&amp;color=#{color}&amp;auto_play=false&amp;show_artwork=true"></iframe>}
	end

	private

	def self.process_data raw_items=[]
		raw_items.map do |item|
			time = Time.parse(item.created_at).getlocal.iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item.to_hash,
				"is_private" => (item.sharing != "public"),
				"url" => item.permalink_url,
				"original_id" => item.id.to_s
			}
		end
	end
end
