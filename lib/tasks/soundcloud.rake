namespace :soundcloud do
	task :favorites do ; LSoundcloud.get_favorites end
	task :backfill_favorites do ; LSoundcloud.get_favorites true end

	task :tracks do ; LSoundcloud.get_tracks end
	task :backfill_tracks do ; LSoundcloud.get_tracks true end
end
