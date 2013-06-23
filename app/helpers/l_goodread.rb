module LGoodread
	def self.get_reviews
		abort "       Please specify GOODREADS_API_KEY" unless ENV["GOODREADS_API_KEY"]
		abort "       Please specify GOODREADS_USER" unless ENV["GOODREADS_USER"]

		url_base = "http://www.goodreads.com/review/list/#{ENV["GOODREADS_USER"]}.xml?key=#{ENV["GOODREADS_API_KEY"]}&v=2"

		total = self.get_data("#{url_base}&per_page=1")["reviews"]["total"].to_i
		per_page = 200 # max: 200
		pages = (total / per_page.to_f).ceil

		puts "*** #{total} reviews"

		1.upto(pages).each_with_index do |page, p_idx|
			data = self.get_data("#{url_base}&per_page=#{per_page}&page=#{page}")["reviews"]["review"]
			items = self.process_data data

			Laminar.add_items "goodreads", "review", items

			sleep 5
		end
	end

	private

	def self.process_data raw_items
		raw_items.map do |item|
			{
				"created_at" => Time.parse(item["date_added"]).iso8601,
				"updated_at" => Time.parse(item["date_updated"]).iso8601,
				"data" => item,
				"url" => item["url"],
				"original_id" => item["id"]
			}
		end
	end

	def self.get_data url=""
		Crack::XML.parse(open(url).read)["GoodreadsResponse"]
	end
end
