namespace :cloudapp do
	task :drops do ; LCloudapp.get_drops end
	task :backfill_drops do ; LCloudapp.get_drops true end
end
