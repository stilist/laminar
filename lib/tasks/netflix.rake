# Note: Assumes you've scraped Netflix's ratings XML.

namespace :netflix do
	task :static_ratings_local do
		items = process_review_data
		upload_to_remote ENV["NETFLIX_RATINGS_FILENAME"], items
	end

	task :static_ratings_remote do
		items = Laminar.get_static_data ENV["NETFLIX_STATIC_RATINGS_URL"]
		add_netflix_items items, "review"
	end

	private

	def process_review_data
		newest = Activity.first.created_at
		# work around `Activity` with an `updated_at` on the Unix epoch
		oldest = Activity.where("updated_at > '1970-01-03'").last.created_at

		data_path = File.expand_path "sources/netflix"
		out = []

		Dir.chdir(data_path) do
			Dir.glob("*.xml") do |path|
				xml = Hash.from_xml IO.read(path)
				items = xml[:ratings][:ratings_item]

				items.each do |item|
					# Since the only data is the release year, `+1` to guarantee the
					# review isn't "from" that year.
					year = Time.local(item[:release_year].to_i + 1)
					start = (year > oldest) ? year : oldest
					range = newest - start
					date = Time.at(start + rand(range.to_i)).iso8601

					url =  item[:link].select { |l| l[:attributes][:title] == "web page" }.first[:attributes][:href]

					out << {
						source: "netflix",
						activity_type: "review",
						url: url,
						created_at: date,
						updated_at: date,
						data: Laminar.sym2s(item),
						# `"not interested"` is in a `Hash`
						is_private: item[:user_rating].is_a?(Hash),
						original_id: item[:id].split("/")[-1]
					}
				end
			end
		end

		out
	end

	def add_netflix_items items, activity_type
		total = items.length

		puts
		puts "-----> Netflix: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item["original_id"]} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "netflix").
						where(activity_type: activity_type).
						where(original_id: item["original_id"]).count

				if existing == 0
					Activity.create(item)
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
