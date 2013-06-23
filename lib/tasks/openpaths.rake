namespace :openpaths do
	task :data do ; LOpenPath.get_data end
	task :backfill_data do ; LOpenPath.get_data true end
end
