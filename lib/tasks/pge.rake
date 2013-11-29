namespace :pge do
	# https://cs.portlandgeneral.com/Secure/EnergyTracker/LoadAnalysis.aspx
	#
	# Switch to ‘Hour-by-Hour Energy Usage’, week mode. ‘Export Data’ will
	# download CSVs.
	#
	# Note: only one year of data is available, unless there’s a simple way to
	# manipulate the form or server requests. (Boo ASP.)
	task :static_local do
		items = LPge.process_local_data
		Laminar.put_static_data ENV["PGE_ELECTRICITY_FILENAME"], items
	end

	task :static_remote do
		items = Laminar.get_static_data ENV["PGE_ELECTRICITY_URL"]
		Laminar.add_items "pge", "electricity", items
	end
end
