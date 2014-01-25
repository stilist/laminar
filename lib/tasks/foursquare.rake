namespace :foursquare do
	task :checkins do ; LFoursquare.get_checkins end
	task :backfill_checkins do ; LFoursquare.get_checkins true end
end
