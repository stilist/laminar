namespace :moves do
	task :storyline do ; LMove.get_storyline end
	task :backfill_storyline do ; LMove.get_storyline true end
end
