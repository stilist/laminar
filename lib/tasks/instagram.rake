namespace :instagram do
	task :authorize do
		puts "Open this URL in your browser to authorize Laminar:"
		puts Instagram.authorize_url(redirect_uri: ENV["INSTAGRAM_AUTHORIZE_URL"])
	end

	task :likes do ; LInstagram.get_data "like" end
	task :backfill_likes do ; LInstagram.get_data "like", true end

	task :photos do ; LInstagram.get_data "photo" end
	task :backfill_photos do ; LInstagram.get_data "photo", true end
end
