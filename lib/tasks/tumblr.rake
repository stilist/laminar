namespace :tumblr do
	task :likes do ; get_tumblr_likes end
	task :backfill_likes do ; get_tumblr_likes true end

	task :posts do ; get_tumblr_posts end
	task :backfill_posts do ; get_tumblr_posts true end

	private

	def add_tumblr_items items, activity_type
		total = items.length

		puts
		puts "-----> Tumblr: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "       #{activity_type}: #{item["slug"]} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "tumblr").
						where(activity_type: activity_type).
						where(original_id: item["id"].to_s).count

				if existing == 0
					# For likes, this is when the post was created, not the like
					time = Time.parse(item["date"]).iso8601

					updated = time["updated"] ? Time.parse(item["updated"]).iso8601 : time

					Activity.create({
						source: "tumblr",
						activity_type: activity_type,
						url: item["post_url"],
						created_at: time,
						updated_at: updated,
						data: item,
						original_id: item["id"].to_s
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def get_tumblr_likes backfill=false
		data = get_tumblr_data("likes")["response"]
		total = data["liked_count"].to_i
		per_page = 20 # max: 20
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "       #{total} likes"

		pages.downto(1).each_with_index do |page, p_idx|
			items = get_tumblr_data("likes",
					{ limit: per_page, offset: (p_idx * per_page) })["response"]["liked_posts"]

			add_tumblr_items items, "like"

			sleep 5
		end
	end

	def get_tumblr_posts backfill=false
		data = get_tumblr_data("posts")["response"]
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
			items = get_tumblr_data("posts", options)["response"]["posts"]

			add_tumblr_items items, "post"

			sleep 5
		end
	end

	def get_tumblr_data path="", extras={}
		url = "http://api.tumblr.com/v2/blog/#{ENV["TUMBLR_BLOG"]}/#{path}?api_key=#{ENV["TUMBLR_API_KEY"]}"
		extras.each { |k,v| url << "&#{k}=#{v}" }
		data = open(url).read

		JSON.parse data
	end
end
