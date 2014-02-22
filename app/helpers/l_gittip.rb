module LGittip
	def self.get_tips
		required_keys = %w(api_key user)
		required_keys.each do |key|
			full = "GITTIP_#{key.upcase}"
			abort "       Please specify #{full}" unless ENV[full]
		end

		auth = { username: ENV["GITTIP_API_KEY"] }
		res = HTTParty.get("https://www.gittip.com/#{ENV["GITTIP_USER"]}/tips.json",
				basic_auth: auth)
		data = JSON.parse(res.body)
		items = self.process_data data

		Laminar.add_items "gittip", "tip", items, { replace: true }
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "tip"
			keys = %w(amount username)
			keys.each { |k| parsed[k.to_sym] = activity[k] }
		end

		parsed
	end

	private

	def self.process_data raw_items=[]
		bow = Date.today.beginning_of_week
		time = bow.to_time.getlocal.iso8601

		raw_items.map do |item|
			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"url" => "https://www.gittip.com/#{item["username"]}/",
				"original_id" => "#{item["username"]}/#{time}"
			}
		end
	end
end
