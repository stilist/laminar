module LTumblr
	def self.oauth_client
		@client ||= OAuth::Consumer.new(ENV["TUMBLR_API_KEY"], ENV["TUMBLR_API_SECRET"], {
			site: "http://www.tumblr.com",
			request_token_path: "/oauth/request_token",
			authorize_path: "/oauth/authorize",
			access_token_path: "/oauth/access_token",
			http_method: :post
		})
	end

	def self.oauth_request_token
		self.oauth_client.get_request_token(oauth_callback: ENV["TUMBLR_AUTHORIZE_URL"])
	end

	def self.get_likes backfill=false
		data = self.get_data("likes")["response"]
		total = data["liked_count"].to_i
		per_page = 20 # max: 20
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "       #{total} likes"

		pages.downto(1).each_with_index do |page, p_idx|
			data = self.get_data("likes", { limit: per_page, offset: (p_idx * per_page) })
			items = self.process_data data["response"]["liked_posts"]

			Laminar.add_items "tumblr", "like", items

			sleep 5
		end
	end

	def self.get_posts backfill=false
		data = self.get_data("posts")["response"]
		total = data["total_posts"].to_i
		per_page = 20 # max: 20
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "       #{total} posts"

		pages.downto(1).each_with_index do |page, p_idx|
			options = {
				filter: "raw",
				limit: per_page,
				notes_info: true,
				offset: (p_idx * per_page),
				reblog_info: true
			}

			data = self.get_data("posts", options)
			items = self.process_data data["response"]["posts"]

			Laminar.add_items "tumblr", "post", items

			sleep 5
		end
	end

	private

	def self.get_data path="", extras={}
		url = "http://api.tumblr.com/v2/blog/#{ENV["TUMBLR_BLOG"]}/#{path}?api_key=#{ENV["TUMBLR_API_KEY"]}"
		extras.each { |k,v| url << "&#{k}=#{v}" }
		data = open(url).read

		JSON.parse data
	end

	def self.process_data raw_items
		raw_items.map do |item|
			# For likes, this is when the post was created, not the like
			time = Time.parse(item["date"]).iso8601

			updated = time["updated"] ? Time.parse(item["updated"]).iso8601 : time

			{
				"created_at" => time,
				"updated_at" => updated,
				"data" => item,
				"url" => item["post_url"],
				"original_id" => item["id"].to_s
			}
		end
	end
end
