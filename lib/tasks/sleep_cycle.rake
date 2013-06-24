# http://www.sleepcycle.com
#
# Getting the database is vastly more complicated than it needs to be.
#
# 1) manually back up your phone with iTunes
# 2) download iPhone Backup Extractor (http://supercrazyawesome.com)
# 3) read the backup you just made
# 4) extract `com.lexwarelabs.goodmorning`
# 5) copy `Documents/eventlog.sqlite` into this app's directory as
#    `sources/sleep_cycle.sqlite`

namespace :sleep_cycle do
	task :local do
		begin
			puts "-----> Sleep Cycle: processing data"

			db = SQLite3::Database.new "sources/sleep_cycle.sqlite"
			items = LSleepCycle.process_data db

			Laminar.put_static_data ENV["SLEEP_CYCLE_FILENAME"], items
		rescue => e
			puts "Sleep Cycle processing failed:"
			puts e
		end
	end

	task :remote do
		items = Laminar.get_static_data ENV["SLEEP_CYCLE_URL"]
		Laminar.add_items "sleep_cycle", "sleep", items
	end
end
