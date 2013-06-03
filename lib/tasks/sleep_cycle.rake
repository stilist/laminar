# require "sqlite3"

# http://www.sleepcycle.com
#
# Getting your data:
# 1) manually back up your phone using iTunes
# 2) download iPhone Backup Extractor (http://supercrazyawesome.com)
# 3) read the backup you just made
# 4) extract `com.lexwarelabs.goodmorning`
# 5) copy out `Documents/eventlog.sqlite`
# 6) upload the file somewhere
# 7) `export SLEEP_CYCLE_URL=that_place`
# 8) `bundle exec rake sleep_cycle:sleeps`

namespace :sleep_cycle do
	task :sleeps do
		begin
			fetch_database
			db = SQLite3::Database.new "sleep_cycle_temp.sqlite"

			items = process_sleep_data db
			add_sleep_cycle_items items, "sleep"
		rescue => e
			puts "Sleep Cycle import failed:"
			puts e
		end
	end

	private

	def process_sleep_data db
		sleep_sessions = []

		db.results_as_hash = true
		sessions = db.execute("select * from ZSLEEPSESSION")

		sessions.each do |session|
			session_id = session["Z_PK"]

			movements = session["ZSTATMOVEMENTSPERHOUR"]
			quality = session["ZSTATSLEEPQUALITY"]
			data = {
				"id" => session_id,
				"sleep_start" => adjust_time(session["ZSESSIONSTART"]),
				"sleep_end" => adjust_time(session["ZSESSIONEND"]),
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
					"timestamp" => adjust_time(event["ZTIME"]).to_s,
					# TODO don't know what this represents, but it does change sometimes
					"type" => event["ZTYPE"]
				}
			end

			sleep_sessions << data
		end

		sleep_sessions
	end

	def add_sleep_cycle_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				id = item["id"].to_s
				puts "  * #{id} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "sleep_cycle").
						where(activity_type: activity_type).
						where(original_id: id).count

				if existing == 0
					Activity.create({
						source: "sleep_cycle",
						activity_type: activity_type,
						created_at: item["sleep_end"],
						updated_at: item["sleep_end"],
						# `.attrs` use: http://stackoverflow.com/a/13249551/672403
						data: item,
						original_id: id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def adjust_time time
		# Cocoa (and thus Core Data) epoch is midnight UTC on 1 January 2001
		time_base = DateTime.new 2001, 01, 01, 0, 0, 0

		Time.at(time_base.to_time + time)
	end

	def fetch_database
		unless ENV["SLEEP_CYCLE_URL"]
			puts "Please set the SLEEP_CYCLE_URL environment variable"
			puts "e.g. export SLEEP_CYCLE_URL=http://foobar.s3.amazonaws.com/sleep_cycle.sqlite"
			abort
		end

		open("sleep_cycle_temp.sqlite", "wb") do |file|
			open(ENV["SLEEP_CYCLE_URL"]) do |uri|
				file.write uri.read
			end
		end
	rescue OpenURI::HTTPError => e
		puts "Unable to fetch database from SLEEP_CYCLE_URL"
	rescue => e
		puts e
	end
end
