(($, window) -> $ ->
	set_video_size = ->
		$(".hfeed .video, .hfeed video").each ->
			$video = $(@)
			ratio = $video.prop("width") / $video.prop("height")
			width = $video.parent().width()

			$video.css
				height: width / ratio
				width: width
	$(window).on "resize.video", set_video_size
	set_video_size()

)(window.$ or window.jQuery or window.Zepto, window)
