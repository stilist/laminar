namespace :pinboard do
	task :bookmarks do ; LPinboard.get_data end
	task :backfill_bookmarks do ; LPinboard.get_data true end
end
