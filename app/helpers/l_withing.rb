# `.constantize` can't deal with the "s"
module LWithing
	def self.client
		@client ||= Withings::Api::Client.new(consumer_key: ENV["WITHINGS_API_KEY"],
			consumer_secret: ENV["WITHINGS_API_SECRET"],
			client_token: ENV["WITHINGS_CLIENT_KEY"],
			client_secret: ENV["WITHINGS_CLIENT_SECRET"],
			uid: ENV["WITHINGS_USER"])
	end

	def self.heart data=[]
		out = {
			"diastolic" => nil,
			"pulse" => nil,
			"systolic" => nil
		}

		data.each do |measure|
			measure_type = case measure["type"]
			when Withings::Api::Constants::DIASTOLIC_BLOOD_PRESSURE then "diastolic"
			when Withings::Api::Constants::HEART_PULSE then "pulse"
			when Withings::Api::Constants::SYSTOLIC_BLOOD_PRESSURE then "systolic"
			end

			out[measure_type] = self.calculate_value(measure) if measure_type
		end

		out
	end

	def self.blood_pressure value=0, type=nil
		# http://www.bloodpressureuk.org/BloodPressureandyou/Thebasics/Bloodpressurechart
		if type == :diastolic
			range = case value.to_i
			when 0..60 then :low
			when 61..80 then :normal
			when 81..90 then :high_normal
			else :high
			end
		elsif type == :systolic
			range = case value.to_i
			when 0..90 then :low
			when 101..120 then :normal
			when 121..140 then :high_normal
			else :high
			end
		else range = nil
		end

		if range
			"#{value} <span class='heart_dot range-#{range}'></span>"
		else
			value
		end
	end

	def self.height data=[], imperial=false
		if data.empty? then nil
		else
			value = self.calculate_value data.first
			# kilograms -> pounds
			imperial ? (value * 3.2808) : value
		end
	end

	def self.weight data=[], imperial=false
		out = {
			"bmi" => nil,
			"lean_mass" => nil,
			"weight" => nil
		}

		data.each do |measure|
			measure_type = case measure["type"]
			when Withings::Api::Constants::FAT_RATIO then "fat_ratio"
			when Withings::Api::Constants::FAT_MASS then "lean_mass"
			when Withings::Api::Constants::WEIGHT then "weight"
			end

			if measure_type
				value = self.calculate_value measure
				if measure_type == "fat_ratio"
					out[measure_type] = value
				else
					# meters -> feet
					out[measure_type] = imperial ? (value * 2.2046) : value
				end
			end
		end

		out
	end

	def self.preprocess_heart_data
		require "csv"

		out = []

		CSV.foreach("sources/withings_heart.csv", headers: :first_row) do |row|
			time = Time.parse "#{row["DATE"]} #{row["HOUR"]}"
			original_id = "#{row["PSEUDO"]}-#{time.to_i}"

			out << {
				created_at: time.iso8601,
				updated_at: time.iso8601,
				original_id: original_id,
				data: {
					systolic: row["SYSTOL"].to_i,
					diastolic: row["DIASTOL"].to_i,
					pulse: row["PULSE"].to_i,
					comment: row["COMMENT"]
				}
			}
		end

		out
	end

	def self.get_data backfill=false
		items = self.client.get_all_data["body"]["measuregrps"]

		weight = items.select do |item|
			item["measures"].select { |measure| measure["type"] == 1 }.length > 0
		end
		non_weight = items - weight

		height = non_weight.select do |item|
			item["measures"].select { |measure| measure["type"] == 4 }.length > 0
		end

		heart = non_weight - height

		{ heart: heart, height: height, weight: weight }.each do |type, data|
			Laminar.add_items "withings", type, self.preprocess_data(data)
		end
	end

	private

	def self.preprocess_data raw_items
		raw_items.map do |item|
			id = item["grpid"].to_s
			time = Time.at(item["date"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"original_id" => id
			}
		end
	end

	def self.calculate_value measure={}
		if measure.is_a? Hash
			# data is in scientific notation
			(measure["value"].to_i * (10 ** measure["unit"].to_i)).to_f
		else
			nil
		end
	end
end
