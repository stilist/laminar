module LSlideshare
	def self.get_favorites backfill=false
		abort "       Please specify SLIDESHARE_USERNAME" unless ENV["SLIDESHARE_USERNAME"]

		@favorite_timestamps = self.get_favorites_timestamps

		id_data = self.get_data "get_user_favorites", { username_for: ENV["SLIDESHARE_USERNAME"] }
		ids = id_data["favorites"]["favorite"].map { |f| f["slideshow_id"] }
		data = ids.map do |id|
			sleep 1

			self.get_slideshow(id)["Slideshow"]
		end

		items = self.process_data data

		Laminar.add_items "slideshare", "favorite", items
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "favorite"
			parsed[:title] = activity["Title"]
			parsed[:description] = activity["Description"]
		end

		parsed
	end

	private

	def self.get_data path="", raw_params={}
		abort "       Please specify SLIDESHARE_API_KEY" unless ENV["SLIDESHARE_API_KEY"]
		abort "       Please specify SLIDESHARE_API_SECRET" unless ENV["SLIDESHARE_API_SECRET"]

		ts = Time.now.to_i

		require "digest/sha1"
		hash = Digest::SHA1.hexdigest "#{ENV["SLIDESHARE_API_SECRET"]}#{ts}"

		raw_params.merge!({
			api_key: ENV["SLIDESHARE_API_KEY"],
			hash: hash,
			ts: ts
		})

		base = "https://www.slideshare.net/api/2/"
		params = raw_params.map { |k,v| "#{k}=#{v}" }.join "&"
		url = "#{base}#{path}?#{params}"

		response = HTTParty.get url
		Crack::XML.parse response.body
	end

	def self.get_favorites_timestamps
		url = "http://www.slideshare.net/rss/user/#{ENV["SLIDESHARE_USERNAME"]}/favorites"

		response = HTTParty.get url
		data = Crack::XML.parse response.body
		items = data["rss"]["channel"]["item"]

		timestamps = items.map do |item|
			[item["link"], Time.parse(item["favDate"]).getlocal.iso8601]
		end

		Hash[timestamps]
	end

	def self.get_slideshow id
		self.get_data "get_slideshow", { slideshow_id: id, detailed: 1 }
	end

	def self.process_data raw_items=[]
		raw_items.map do |item|
			# API doesn’t include timestamp for favorite--try to cheat by pulling it
			# from RSS; if that doesn’t work, generate something plausible.
			permalink = "http://www.slideshare.net/slideshow/view?login=#{item["Username"]}&title=#{item["StrippedTitle"]}"
			time = @favorite_timestamps[permalink]

			unless time
				created = Time.parse(item["Created"]).getlocal.to_i
				now = Time.now.to_i
				time = Time.at(rand(created..now)).getlocal.iso8601
			end

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"url" => permalink,
				"is_private" => (item["PrivacyLevel"] != "0"),
				"original_id" => item["ID"]
			}
		end
	end
end
