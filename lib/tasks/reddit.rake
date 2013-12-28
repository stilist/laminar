namespace :reddit do
	task :all do ; LReddit.get_all end
	task :backfill_all do ; LReddit.get_all true end

	task :comments do ; LReddit.get_comments end
	task :backfill_comments do ; LReddit.get_comments true end

	task :submitted do ; LReddit.get_submitted end
	task :backfill_submitted do ; LReddit.get_submitted true end

	task :liked do ; LReddit.get_liked end
	task :backfill_liked do ; LReddit.get_liked true end

	task :disliked do ; LReddit.get_disliked end
	task :backfill_disliked do ; LReddit.get_disliked true end

	task :hidden do ; LReddit.get_hidden end
	task :backfill_hidden do ; LReddit.get_hidden true end

	task :saved do ; LReddit.get_saved end
	task :backfill_saved do ; LReddit.get_saved true end
end
