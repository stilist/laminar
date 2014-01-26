module LFlightaware
	def self.client
		required_keys = %w(api_key user)
		required_keys.each do |key|
			full = "FLIGHTAWARE_#{key.upcase}"
			abort "       Please specify #{full}" unless ENV[full]
		end

		@client ||= FlightXML2REST.new ENV["FLIGHTAWARE_USER"], ENV["FLIGHTAWARE_API_KEY"]
	end

	def self.get_track flight_id
		client = self.client

		response = client.GetHistoricalTrack GetHistoricalTrackRequest.new flight_id
		data = response.getHistoricalTrackResult.data
		items = self.process_data data, flight_id

		Laminar.add_items "flightaware", "track", [items], { replace: true }
	end

	def self.parse_locations data
		out = []

		points = eval data["points"]
		points.each do |row|
			out << {
				is_path: true,
				altitude: (row["altitude"] * 100),
				lat: row["latitude"],
				lng: row["longitude"],
				arrived_at: Time.at(row["timestamp"]).getlocal.iso8601
			}
		end

		out
	end

	private

	def self.process_data raw_data=[], flight_id
		first = raw_data.first
		time = Time.at(first.timestamp).getlocal.iso8601
		data = self.process_trackpoints raw_data

		{
			"created_at" => time,
			"updated_at" => time,
			"data" => { points: data },
			"is_private" => true,
			"original_id" => flight_id
		}
	end

	def self.process_trackpoints trackpoints=[]
		keys = [:altitude, :altitudeChange, :altitudeStatus, :groundspeed,
				:latitude, :longitude, :timestamp, :updateType]

		trackpoints.map do |point|
			Hash[keys.map { |k| [k.to_s, point.send(k)] }]
		end
	end
end
