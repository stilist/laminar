namespace :wikipedia do
	task :edits do ; get_wikipedia_edits end

	private

	def get_wikipedia_edits
		if ENV["WIKIPEDIA_USER"]
			YAML::ENGINE.yamler = "syck"
			url = "http://en.wikipedia.org/w/api.php?action=query&list=usercontribs&ucuser=#{ENV["WIKIPEDIA_USER"]}&uclimit=500&ucdir=newer&format=json"
			data = Crack::JSON.parse open(url, "User-Agent" => "Laminar/1.1").read
			items = data["query"]["usercontribs"]

			add_wikipedia_items items, "edit"
		else
			puts "Please export WIKIPEDIA_USER"
		end
	rescue => e
		puts ":("
		puts e
	end

	def add_wikipedia_items items, activity_type
		total = items.length

		puts
		puts "-----> Wikipedia: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				puts "       #{activity_type}: #{item["title"]} [#{idx + 1}/#{total}]"

				original_id = "#{item["pageid"]}-#{item["revid"]}"

				existing = Activity.unscoped.where(source: "wikipedia").
						where(activity_type: activity_type).
						where(original_id: original_id).count

				if existing == 0
					time = Time.at(item["timestamp"]).iso8601

					Activity.create({
						source: "wikipedia",
						activity_type: activity_type,
						url: "http://en.wikipedia.org/w/index.php?diff=#{item["revid"]}&oldid=#{item["parentid"]}",
						created_at: time,
						updated_at: time,
						data: item,
						original_id: original_id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
