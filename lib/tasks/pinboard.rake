namespace :pinboard do
	task :bookmarks do
		pinboard = Pinboard::Client.new(username: ENV["PINBOARD_USER"],
				password: ENV["PINBOARD_PASSWORD"])

		existing = Activity.where(source: "pinboard")
				.where(activity_type: "bookmark").count

		# This runs every ten minutes, so pulling the 100 most recent results
		# should be more than enough.
		items = existing == 0 ? pinboard.posts : pinboard.posts(results: 100)
		add_pinboard_items items, "bookmark"
	end

	def add_pinboard_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		ActiveRecord::Base.record_timestamps = false
		items.each_with_index do |item, idx|
			puts "  * #{item.href} [#{idx + 1}/#{total}]"

			existing = Activity.where(url: item.href).count

			if existing == 0
				Activity.create({
					source: "pinboard",
					activity_type: activity_type,
					url: item.href,
					created_at: item.time,
					updated_at: item.time,
					is_private: !item.shared.nil?,
					data: construct_pinboard_data(item)
				})
			end
		end
		ActiveRecord::Base.record_timestamps = true
	end

	def construct_pinboard_data item
		keys = %w(href description extended tag time replace shared toread)
		out = {}
		keys.each { |k| out[k] = item.send k.to_sym }

		out
	end
end
