# Note: Assumes you've scraped Netflix's ratings XML.

namespace :netflix do
	task :static_ratings_local do
		begin
			items = process_review_data
			upload_netflix_remote items
		rescue => e
			puts "Netflix processing failed:"
			puts e
		end
	end

	task :static_ratings_remote do
		begin
			items = fetch_netflix_json

			add_netflix_items items, "review"
		rescue => e
			puts "Netflix import failed:"
			puts e
		end
	end

	private

	def process_review_data
		newest = Activity.first.created_at
		# work around `Activity` with an `updated_at` on the Unix epoch
		oldest = Activity.where("updated_at > '1970-01-03'").last.created_at

		data_path = File.expand_path "netflix"
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

	def upload_netflix_remote items
		storage = Fog::Storage.new({
			provider: ENV["FOG_PROVIDER"],
			aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
			aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
		})

		directory = storage.directories.get ENV["FOG_DIRECTORY"]

		file = directory.files.get ENV["NETFLIX_RATINGS_FILENAME"]

		json = items.to_json

		if file
			file.body = json
			file.public = true
		else
			file = directory.files.create({
				key: ENV["NETFLIX_RATINGS_FILENAME"],
				body: json,
				public: true
			})
			puts "export NETFLIX_STATIC_RATINGS_URL=#{file.public_url}"
		end

		file.save
	rescue => e
		puts "Failed to upload data:"
		puts e
	end

	def add_netflix_items items, activity_type
		total = items.length

		puts
		puts "-----> Netflix: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "  * #{item["original_id"]} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "netflix").
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

	def fetch_netflix_json
		unless ENV["NETFLIX_STATIC_RATINGS_URL"]
			puts "Please set the NETFLIX_STATIC_RATINGS_URL environment variable"
			puts "e.g. export NETFLIX_STATIC_RATINGS_URL=http://foobar.s3.amazonaws.com/netflix_ratings.json"
			abort
		end

		data = open(ENV["NETFLIX_STATIC_RATINGS_URL"]).read
		JSON.parse data
	rescue OpenURI::HTTPError => e
		abort "Unable to fetch database from NETFLIX_STATIC_RATINGS_URL"
	rescue => e
		abort e
	end
end
