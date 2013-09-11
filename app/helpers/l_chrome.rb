module LChrome
	def self.get_data
		# TODO Support other platforms
		original_path = File.expand_path "~/Library/Application Support/Google/Chrome/Default/History"
		# `original_path` will have a filesystem lock if Chrome is running
		self.copy_data original_path

		db = SQLite3::Database.new "sources/chrome.sqlite"

		visits = db.execute "select count(id) from visits"
		puts "-----> Chrome: #{visits[0][0]} page(s) in history"

		self.process_data db
	end

	private

	def self.timestamp_to_time timestamp
		# http://productforums.google.com/d/msg/chrome/ShKTNCQQhlA/-4qHZmQb4-MJ
		#
		# > The internal representation of Time uses FILETIME, whose epoch is
		# > 1601-01-01 00:00:00 UTC and is measured in milliseconds. In short,
		# > subtract 11644473600000000 and divide by a million to get a UNIX epoch
		# > time.
		corrected = (timestamp - 11644473600000000) / 1_000_000

		Time.at(corrected).iso8601
	end

	def self.copy_data path ; FileUtils.cp path, "sources/chrome.sqlite" end

	def self.process_data db
		db.results_as_hash = true

		visits = db.execute "select urls.url, urls.title, visits.id, visits.visit_time, visits.from_visit from visits join urls on visits.url = urls.id order by visit_time asc"

		visits.map do |visit|
			time = self.timestamp_to_time visit["visit_time"]

			data = {
				"title" => visit["title"]
			}

			# TODO Should happen in primary query, but I’m not clever enough
			if visit["from_visit"] != 0
				referrer = db.execute "select url, title from urls where id=?", visit["from_visit"]

				if referrer.length > 0
					data["referrer_title"] = referrer[0]["title"]
					data["referrer_url"] = referrer[0]["url"]
				end
			end

			{
				"created_at" => time,
				"updated_at" => time,
				"url" => visit["url"],
				"data" => data,
				"is_private" => true,
				"original_id" => visit["id"].to_s
			}
		end
	end
end
