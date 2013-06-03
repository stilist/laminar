namespace :youtube do
	task :favorites do
		get_youtube_favorites
	end

	task :backfill_favorites do
		get_youtube_favorites true
	end

	private

	def get_youtube_favorites use_start_index=false
		delay = 10 # No stated limit, so just pick a number.
		per_page = 50 # max: 50

		if use_start_index
			total = get_youtube_data({ per_page: 1 })["feed"]["openSearch$totalResults"]["$t"]
			pages = (total / per_page.to_f).ceil
		else
			pages = 1
		end

		1.upto(pages).each_with_index do |page, p_idx|
			items = get_youtube_data({ per_page: per_page, page: page })["feed"]["entry"]

			add_youtube_items items, "favorite"

			sleep delay
		end
	end

	def get_youtube_data options={}
		require "multi_json"
		require "open-uri"

		base_url = "http://gdata.youtube.com/feeds/api/users/#{ENV["YOUTUBE_USER"]}/favorites?"
		options[:per_page] ||= 25 # default
		options[:page] ||= 0

		params = {
			alt: "json",
			key: ENV["YOUTUBE_API_KEY"],
			"max-results" => options[:per_page],
		}
		params["start-index"] = (options[:page] * options[:per_page]) if options[:page] > 0
		url = base_url + params.map { |k,v| "#{k}=#{v}" }.join("&")
		puts "-----> #{url}"

		data = open(url).read
		MultiJson.load data
	rescue Exception => e
		puts "       ERROR: #{e}"

		{}
	end

	def add_youtube_items items, activity_type
		total = items.length

		puts
		puts "*** #{total} new #{activity_type}(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item["title"]["$t"]} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "youtube").
						where(activity_type: activity_type).
						where(original_id: item["id"]["$t"]).unscoped.count

				if existing == 0
					time = DateTime.parse item["published"]["$t"]
					Activity.create({
						source: "youtube",
						activity_type: activity_type,
						url: item["link"].first["href"],
						created_at: time,
						updated_at: time,
						is_private: item.has_key?("app$control"),
						original_id: item["id"]["$t"],
						data: item
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
