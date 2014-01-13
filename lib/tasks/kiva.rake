namespace :kiva do
	task :loans do ; LKiva.get_loans end
	task :backfill_loans do ; LKiva.get_loans true end
end
