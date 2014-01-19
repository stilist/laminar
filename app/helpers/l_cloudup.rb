module LCloudup
	def self.get_uploads backfill=false
		s_headers, s_data = self.get_data "/items", { only: "id" }
		total = s_headers["x-total"].to_i
		per_page = s_data.length
		pages = backfill ? (total / per_page.to_f).ceil : 1

		rate_limit = [(s_headers["x-ratelimit-limit"].to_i / 60 / 60) * 1.25, 1].max

		path = "/items"
		1.upto(pages).each_with_index do |page, p_idx|
			headers, data = self.get_data path
			items = self.process_data data

			puts " *" * 10
			puts items.to_json

			Laminar.add_items "cloudup", "upload", items, { replace: true }

			# set up next request--header looks like:
			#     "<https://api.cloudup.com/items?page=2>; rel=\"next\""`
			path = headers["link"].match(/<.*(\/items.*)>/)[1]

			sleep rate_limit if p_idx < (pages - 1)
		end
	end

	def self.parse_activity activity, activity_type
		parsed = {}

		case activity_type
		when "upload"
			keys = %w(direct_url filename mime thumb_url title type)
			keys.each { |k| parsed[k.to_sym] = activity[k] }
		end

		parsed
	end

	private

	def self.get_data path, raw_params={}
		required_keys = %w(password user)
		required_keys.each do |key|
			full = "CLOUDUP_#{key.upcase}"
			abort "       Please specify #{full}" unless ENV[full]
		end

		params = raw_params.map { |k,v| "#{k}=#{v}" }.join "&"
		url = "https://api.cloudup.com/1#{path}?#{params}"

		res = HTTParty.get url, basic_auth: {
			username: ENV["CLOUDUP_USER"],
			password: ENV["CLOUDUP_PASSWORD"]
		}

		[res.headers, JSON.parse(res.body)]
	end

	def self.process_data raw_items=[]
		raw_items.map do |item|
			time = Time.parse(item["completed_at"]).getlocal.iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"is_private" => true,
				"url" => item["url"],
				"original_id" => item["id"]
			}
		end
	end
end
