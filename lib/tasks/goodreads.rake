namespace :goodreads do
	task :reviews do ; get_goodreads_reviews end

	private

	def get_goodreads_reviews
		if ENV["GOODREADS_APP_KEY"] && ENV["GOODREADS_USER"]
			url_base = "http://www.goodreads.com/review/list/#{ENV["GOODREADS_USER"]}.xml?key=#{ENV["GOODREADS_APP_KEY"]}&v=2"

			total = get_data("#{url_base}&per_page=1")["reviews"]["total"].to_i

			per_page = 200 # max: 200
			pages = (total / per_page.to_f).ceil

			puts "*** #{total} reviews"

			pages.downto(1).each_with_index do |page, p_idx|
				items = get_data("#{url_base}&per_page=#{per_page}&page=#{page}")["reviews"]["review"]

				add_goodreads_items items, "review"

				sleep 5
			end
		end
	end

	def add_goodreads_items items, activity_type
		total = items.length

		puts
		puts "-----> Goodreads: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "       #{activity_type}: #{item["book"]["title"]} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "goodreads").
						where(activity_type: activity_type).
						where(original_id: item["id"]).count

				if existing == 0
					time = Time.parse(item["date_updated"]).iso8601

					Activity.create({
						source: "goodreads",
						activity_type: activity_type,
						url: item["url"],
						created_at: Time.parse(item["date_updated"]).iso8601,
						updated_at: Time.parse(item["date_added"]).iso8601,
						data: item,
						original_id: item["id"]
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end

	def get_data url=""
		Crack::XML.parse(open(url).read)["GoodreadsResponse"]
	end
end
