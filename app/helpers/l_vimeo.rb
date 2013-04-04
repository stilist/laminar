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
end
