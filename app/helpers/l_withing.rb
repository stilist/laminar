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
			diastolic: nil,
			pulse: nil,
			systolic: nil
		}

		data.each do |measure|
			measure_type = case measure["type"]
			when Withings::Api::Constants::DIASTOLIC_BLOOD_PRESSURE then :diastolic
			when Withings::Api::Constants::HEART_PULSE then :pulse
			when Withings::Api::Constants::SYSTOLIC_BLOOD_PRESSURE then :systolic
			end

			out[measure_type] = self.calculate_value(measure) if measure_type
		end

		out
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
			bmi: nil,
			lean_mass: nil,
			weight: nil
		}

		data.each do |measure|
			measure_type = case measure["type"]
			when Withings::Api::Constants::FAT_RATIO then :fat_ratio
			when Withings::Api::Constants::FAT_MASS then :lean_mass
			when Withings::Api::Constants::WEIGHT then :weight
			end

			if measure_type
				value = self.calculate_value measure
				if measure_type == :fat_ratio
					out[measure_type] = value
				else
					# meters -> feet
					out[measure_type] = imperial ? (value * 2.2046) : value
				end
			end
		end

		out
	end

	private

	def self.calculate_value measure={}
		if measure.is_a? Hash
			# data is in scientific notation
			(measure["value"].to_i * (10 ** measure["unit"].to_i)).to_f
		else
			nil
		end
	end
end
