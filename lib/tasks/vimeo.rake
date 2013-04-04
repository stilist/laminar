namespace :vimeo do
	task :backfill_likes do
		vimeo = LVimeo.client
		opts = { full_response: 1, sort: "oldest" }

		total = vimeo.get_likes(ENV["VIMEO_USER"],
				opts.merge({ page: 1, per_page: 1 }))["videos"]["total"].to_i
		per_page = 50 # max: 50
		pages = (total / per_page.to_f).ceil

		puts "*** #{total} likes"

		pages.downto(1).each_with_index do |page, p_idx|
			items = vimeo.get_likes(ENV["VIMEO_USER"],
					opts.merge({ page: page, per_page: per_page }))["videos"]["video"]

			add_vimeo_items items, "like"

			# 1500 requests per user per 5 minutes (= 5 per second)
			sleep 1
		end
	end

	task :likes do
		vimeo = LVimeo.client
		opts = { full_response: 1, sort: "newest", per_page: 50 }

		# No window/cursor options, so just pull the n most recent and trust
		# duplicate-checking.
		items = vimeo.get_likes(ENV["VIMEO_USER"],
				opts.merge({ page: 1 }))["videos"]["video"]

		add_vimeo_items items, "like"
	end

	private

	def add_vimeo_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item["title"]} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "vimeo").
						where(activity_type: "like").where(original_id: item["id"]).count

				if existing == 0
					# Comes through without a time zone specified, but seems to be in
					# Eastern Time. Pick an offset; close enough.
					time = DateTime.parse("#{item["liked_on"]} +0500")

					Activity.create({
						source: "vimeo",
						activity_type: activity_type,
						url: item["urls"]["url"].first["_content"],
						created_at: time,
						updated_at: time,
						is_private: (!item["privacy"] == "anybody"),
						original_id: item["id"],
						data: item
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end