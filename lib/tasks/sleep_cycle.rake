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
			db = SQLite3::Database.new "sources/sleep_cycle.sqlite"

			puts "-----> Sleep Cycle: processing data"

			items = process_sleep_data db
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

	private

	def process_sleep_data db
		out = []

		db.results_as_hash = true
		sessions = db.execute("select * from ZSLEEPSESSION")

		puts "       Processing #{sessions.length} sleep session(s)"

		sessions.each do |session|
			item = {}

			session_id = session["Z_PK"]

			movements = session["ZSTATMOVEMENTSPERHOUR"]
			quality = session["ZSTATSLEEPQUALITY"]
			data = {
				"sleep_start" => adjust_sleep_timestamp(session["ZSESSIONSTART"]).to_s,
				"sleep_end" => adjust_sleep_timestamp(session["ZSESSIONEND"]).to_s,
				"duration" => session["ZSTATTOTALDURATION"],
				"rating" => session["ZRATING"] || 0,
				# seems to be a newer column
				"offset" => session["ZSECONDSFROMGMT"],
				"movements" => movements ? movements.round : 0,
				"quality" => quality ? (quality * 100).round : 0
			}

			db.results_as_hash = false
			notes = db.execute("select ZSLEEPNOTE.ZNAME from Z_3SLEEPSESSIONS join ZSLEEPNOTE on Z_3SLEEPSESSIONS.Z_3SLEEPNOTES = ZSLEEPNOTE.Z_PK where Z_3SLEEPSESSIONS.Z_4SLEEPSESSIONS = #{session_id} order by ZSLEEPNOTE.ZNAME asc").flatten
			data["notes"] = notes

			db.results_as_hash = true
			events = db.execute "select ZINTENSITY, ZTIME, ZTYPE from ZSLEEPEVENT where ZSLEEPSESSION = #{session_id}"
			data["events"] = events.map do |event|
				{
					"intensity" => event["ZINTENSITY"],
					"timestamp" => adjust_sleep_timestamp(event["ZTIME"]).to_s,
					# TODO don't know what this represents, but it does change sometimes
					"type" => event["ZTYPE"]
				}
			end

			item.merge!({
				"created_at" => data["sleep_end"],
				"updated_at" => data["sleep_end"],
				"data" => data,
				"original_id" => session_id.to_s
			})

			out << item
		end

		out
	end

	def adjust_sleep_timestamp time
		# Cocoa (and thus Core Data) epoch is midnight UTC on 1 January 2001
		time_base = DateTime.new 2001, 01, 01, 0, 0, 0

		Time.at(time_base.to_time + time).iso8601
	end
end
