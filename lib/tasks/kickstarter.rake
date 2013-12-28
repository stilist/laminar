namespace :kickstarter do
	task :backed do ; LKickstarter.get_backed end
	task :backfill_backed do ; LKickstarter.get_backed true end
end
