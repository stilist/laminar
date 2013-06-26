module LSleepCycle
	def self.process_data db
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
				"sleep_start" => Laminar.adjust_core_data_timestamp(session["ZSESSIONSTART"]).to_s,
				"sleep_end" => Laminar.adjust_core_data_timestamp(session["ZSESSIONEND"]).to_s,
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
					"timestamp" => Laminar.adjust_core_data_timestamp(event["ZTIME"]).to_s,
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
end
