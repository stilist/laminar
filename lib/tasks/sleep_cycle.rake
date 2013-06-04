# http://www.sleepcycle.com
#
# Getting the database is vastly more complicated than it needs to be.
#
# 1) manually back up your phone with iTunes
# 2) download iPhone Backup Extractor (http://supercrazyawesome.com)
# 3) read the backup you just made
# 4) extract `com.lexwarelabs.goodmorning`
# 5) copy `Documents/eventlog.sqlite` into this app's directory

namespace :sleep_cycle do
	task :sleeps => [:local, :remote]

	task :local do
		begin
			db = SQLite3::Database.new "sleep_cycle.sqlite"

			items = process_sleep_data db
			upload_to_remote items
		rescue => e
			puts "Sleep Cycle processing failed:"
			puts e
		end
	end

	task :remote do
		begin
			items = fetch_sleep_json

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

		sessions.reverse.each do |session|
			session_id = session["Z_PK"]

			movements = session["ZSTATMOVEMENTSPERHOUR"]
			quality = session["ZSTATSLEEPQUALITY"]
			data = {
				"id" => session_id,
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

			sleep_sessions << data
		end

		sleep_sessions
	end

	def adjust_sleep_timestamp time
		# Cocoa (and thus Core Data) epoch is midnight UTC on 1 January 2001
		time_base = DateTime.new 2001, 01, 01, 0, 0, 0

		Time.at(time_base.to_time + time).iso8601
	end

	def upload_to_remote items
		storage = Fog::Storage.new({
			provider: ENV["FOG_PROVIDER"],
			aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
			aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
		})

		directory = storage.directories.get ENV["FOG_DIRECTORY"]

		file = directory.files.get ENV["SLEEP_CYCLE_FILENAME"]

		json = items.to_json

		if file
			file.body = json
			file.public = true
		else
			file = directory.files.create({
				key: ENV["SLEEP_CYCLE_FILENAME"],
				body: json,
				public: true
			})
			puts "export SLEEP_CYCLE_URL=#{file.public_url}"
		end

		file.save
	rescue => e
		puts "Failed to upload data:"
		puts e
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
						data: item,
						original_id: id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def fetch_sleep_json
		unless ENV["SLEEP_CYCLE_URL"]
			puts "Please set the SLEEP_CYCLE_URL environment variable"
			puts "e.g. export SLEEP_CYCLE_URL=http://foobar.s3.amazonaws.com/sleep_cycle.json"
			abort
		end

		data = open(ENV["SLEEP_CYCLE_URL"]).read
		JSON.parse data
	rescue OpenURI::HTTPError => e
		abort "Unable to fetch database from SLEEP_CYCLE_URL"
	rescue => e
		abort e
	end
end
