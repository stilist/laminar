namespace :fitbit do
	task :activity do ; LFitbit.get_activity end
	task :backfill_activity do ; LFitbit.get_activity true end
end
