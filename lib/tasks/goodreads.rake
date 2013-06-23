namespace :goodreads do
	task :reviews do ; LGoodread.get_reviews end
end
