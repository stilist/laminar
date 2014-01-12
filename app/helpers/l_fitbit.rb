module LFitbit
	def self.client options={}
		defaults = {
			consumer_key: ENV["FITBIT_API_KEY"],
			consumer_secret: ENV["FITBIT_API_SECRET"]
		}
		@client ||= Fitgem::Client.new defaults.merge(options)

		if ENV["FITBIT_CLIENT_KEY"] && ENV["FITBIT_CLIENT_SECRET"]
			@client.reconnect ENV["FITBIT_CLIENT_KEY"], ENV["FITBIT_CLIENT_SECRET"]
		end

		@client
	end

	def self.get_activity backfill=false
		delay = (60 * 60) / 150 # 150 requests/hour

		abort "       Please specify FITBIT_CLIENT_KEY" unless ENV["FITBIT_CLIENT_KEY"]
		abort "       Please specify FITBIT_CLIENT_SECRET" unless ENV["FITBIT_CLIENT_SECRET"]

		if backfill
			start_date = Date.parse self.client.user_info["user"]["memberSince"]
		else
			start_date = Date.today
		end
		# `Range` can only run forwards, so cast to `Array`
		dates = [*start_date..Date.today].reverse

		puts "-----> Fitbit: #{dates.length} dates(s)"

		dates.each do |date|
			puts "       #{date.to_s}"

			data = self.client.activities_on_date date.to_s

			# catch rate-limiting
			if data.has_key? "errors"
				abort "-----> hit rate limit"
			else
				item = self.process_data data, date
				Laminar.add_items "fitbit", "activity", [item], { replace: true }

				sleep delay
			end
		end
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "activity"
			summary = Laminar.hstore2hash activity["summary"]

			parsed[:steps] = summary["steps"]

			times = {
				light: summary["lightlyActiveMinutes"],
				moderate: summary["fairlyActiveMinutes"],
				high: summary["veryActiveMinutes"]
			}
			active_sum = times[:light] + times[:moderate] + times[:high]
			times[:inactive] = ((60 * 24) - active_sum)

			parsed[:times] = times
		end

		parsed
	end

	private

	def self.process_data raw_item, date
		timestamp = date.to_time.iso8601

		{
			"created_at" => timestamp,
			"updated_at" => timestamp,
			"data" => raw_item,
			"original_id" => timestamp
		}
	end
end
