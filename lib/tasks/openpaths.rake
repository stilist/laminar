namespace :openpaths do
	task :data do ; get_openpaths_data end
	task :backfill_data do ; get_openpaths_data true end

	private

	def get_openpaths_data backfill=false
		num_points = backfill ? 2000 : 50 # max: 2000

		# https://gist.github.com/pdarche/5034801
		base_url = "https://openpaths.cc/api/1"
		credentials = Crazylegs::Credentials.new ENV["OPENPATHS_CLIENT_KEY"], ENV["OPENPATHS_CLIENT_SECRET"]
		url = Crazylegs::SignedURL.new credentials, base_url, "GET"
		signed_url = url.full_url
		# http://stackoverflow.com/a/15821224/672403
		options = { num_points: num_points }
		res = HTTParty.get signed_url, query: options
		items = JSON.parse res.parsed_response

		add_openpaths_items items, "location"
	end

	def add_openpaths_items items, activity_type
		total = items.length

		puts
		puts "-----> OpenPaths: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				id = item["t"].to_s

				puts "       #{activity_type}: #{id} [#{idx + 1}/#{total}]"

				existing = Activity.unscoped.where(source: "openpaths").
						where(activity_type: activity_type).
						where(original_id: id).count

				if existing == 0
					time = Time.at(item["t"]).iso8601

					Activity.create({
						source: "openpaths",
						activity_type: activity_type,
						created_at: time,
						updated_at: time,
						data: item,
						is_private: true,
						original_id: id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
