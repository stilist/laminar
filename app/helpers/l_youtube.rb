module LYoutube
	def self.get_t data="{}" ; eval(data)["$t"] end

	def self.media data
		# Convert e.g. `http://gdata.youtube.com/feeds/api/videos/ONZcjs1Pjmk` to
		# `ONZcjs1Pjmk`
		id = get_t(data["id"]).split("/")[-1]

		# YouTube data doesn't pass dimensions, so make some up--doesn't really
		# matter since JS will resize it anyhow.
		"<iframe src='//www.youtube.com/embed/#{id}' height='360' width='480'
				frameborder='0' webkitAllowFullScreen mozallowfullscreen
				allowFullScreen class='video' modestbranding='1' rel='0'></iframe>"
	end
end
