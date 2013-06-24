namespace :goodreads do
	task :reviews do ; LGoodread.get_reviews end
	task :backfill_reviews do ; LGoodread.get_reviews true end
end
