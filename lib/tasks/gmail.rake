namespace :gmail do
	task :received do ; LGmail.get_received end
	task :backfill_received do ; LGmail.get_received true end

	task :sent do ; LGmail.get_sent end
	task :backfill_sent do ; LGmail.get_sent true end
end
