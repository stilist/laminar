namespace :cloudup do
	task :uploads do ; LCloudup.get_uploads end
	task :backfill_uploads do ; LCloudup.get_uploads true end
end
