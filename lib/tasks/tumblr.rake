namespace :tumblr do
	task :likes do ; LTumblr.get_likes end
	task :backfill_likes do ; LTumblr.get_likes true end

	task :posts do ; LTumblr.get_posts end
	task :backfill_posts do ; LTumblr.get_posts true end
end
