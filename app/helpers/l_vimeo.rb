module LVimeo
	def self.client
		@client ||= Vimeo::Advanced::Video.new(
			ENV["VIMEO_APP_KEY"],
			ENV["VIMEO_APP_SECRET"],
			token: ENV["VIMEO_USER_KEY"],
			secret: ENV["VIMEO_USER_SECRET"]
		)
	end

	def self.person_link data
		user = data["owner"].is_a?(String) ? eval(data["owner"]) : data["owner"]
		"<a href='#{user["profile_url"]}'>#{user["realname"]}</a>"
	end

	def self.media data, hsl
		# Use range because `.hex` includes `#`, which Vimeo doesn't like
		color = ColorMath::HSL.new(*hsl).hex[1..-1]

		url = "http://player.vimeo.com/video/#{data["id"]}?title=0&byline=0&portrait=0&color=#{color}"

		"<iframe src='#{url}' height='#{data["height"]}' width='#{data["width"]}'
				frameborder='0' webkitAllowFullScreen mozallowfullscreen
				allowFullScreen class='video'></iframe>"
	end

	def self.get_videos backfill=false
		activity_type = "video"

		total = self.get_data(:get_uploaded, { per_page: 1 })["videos"]["total"].to_i
		pages = backfill ? (total / per_page.to_f).ceil : 1

		1.upto(pages).each_with_index do |page, p_idx|
			data = self.get_data(:get_uploaded, { page: page })["videos"]["video"]
			items = self.process_data data, activity_type

			Laminar.add_items "vimeo", activity_type, items

			# 1500 requests per user per 5 minutes (= 5 per second)
			sleep 1
		end
	end

	def self.get_likes backfill=false
		self.get_data({
			activity_type: "like",
			backfill: backfill,
			method: :get_likes
		})
	end

	def self.get_videos backfill=false
		self.get_data({
			activity_type: "video",
			backfill: backfill,
			method: :get_uploaded
		})
	end

	private

	def self.get_data options={}
		activity_type = options.delete :activity_type
		backfill = options.delete :backfill
		method = options.delete :method

		defaults = {
			full_response: 1,
			page: 1,
			per_page: 50, # max: 50
			sort: "newest"
		}
		settings = defaults.merge(options)

		total = self.remote_call(method, { per_page: 1 })["total"].to_i
		pages = backfill ? (total / settings[:per_page].to_f).ceil : 1

		1.upto(pages).each do |page|
			settings[:page] = page

			data = self.remote_call(method, settings)["video"]
			items = self.process_data data, activity_type

			Laminar.add_items "vimeo", activity_type, items

			# 1500 requests per user per 5 minutes (= 5 per second)
			sleep 1
		end
	end

	def self.process_data raw_items, type
		raw_items.map do |item|
			# Comes through without a time zone specified, but seems to be in
			# Eastern Time. Pick an offset; close enough.
			time_field = type == "like" ? "liked_on" : "upload_date"
			time = Time.parse("#{item[time_field]} -0500").iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"is_private" => (item["privacy"] != "anybody"),
				"url" => item["urls"]["url"].first["_content"],
				"original_id" => item["id"],
				"data" => item
			}
		end
	end

	def self.remote_call method, options={}
		abort "       Please specify VIMEO_USER" unless ENV["VIMEO_USER"]

		self.client.send(method, ENV["VIMEO_USER"], options)["videos"]
	end
end
