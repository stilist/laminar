namespace :vimeo do
	task :likes do ; LVimeo.get_likes end
	task :backfill_likes do ; LVimeo.get_likes true end

	task :videos do ; LVimeo.get_videos end
	task :backfill_videos do ; LVimeo.get_videos true end
end
