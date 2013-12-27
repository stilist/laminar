namespace :coinbase do
	task :transactions do ; LCoinbase.get_transactions end
	task :backfill_transactions do ; LCoinbase.get_transactions true end
end
