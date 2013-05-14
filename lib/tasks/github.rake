namespace :github do
	task :authorize do
		puts "Open this URL in your browser to authorize Laminar:"
		puts LGithub.client.authorize_url(redirect_uri: ENV["GITHUB_AUTHORIZE_URL"],
				scope: "repo")
	end

	task :activity do ; get_github_activity end
	task :backfill_activity do ; get_github_activity true end

	private

	def get_github_activity backfill=false
		delay = (60 * 60) / 5000 # 5000 requests/hour

		if ENV["GITHUB_CLIENT_KEY"]
			gh = LGithub.client({ oauth_token: ENV["GITHUB_CLIENT_KEY"] })

			puts " *" * 10
			items = gh.activity.events.user_performed ENV["GITHUB_USER"]

			add_github_items items

			if backfill
				# Will fetch up to 300 items
				while items.has_next_page?
					items = items.next_page
					add_github_items items

					sleep delay
				end
			end
		end
	end

	def add_github_items items
		total = items.length

		puts
		puts "-----> GitHub: processing #{total} item(s)"

		begin
			ActiveRecord::Base.record_timestamps = false
			items.each_with_index do |item, idx|
				activity_type = item.type.sub("Event", "").underscore

				puts "       #{activity_type} #{item.repo.name} [#{idx + 1}/#{total}]"

				existing = Activity.where(source: "github").
						where(activity_type: activity_type).
						where(original_id: item["id"]).count

				if existing == 0
					time = DateTime.parse item.created_at

					data = {}
					item.each { |k,v| data[k] = v.is_a?(Hashie::Mash) ? v.to_hash : v }

					Activity.create({
						source: "github",
						activity_type: activity_type,
						url: item.repo.url,
						created_at: time,
						updated_at: time,
						is_private: item.public,
						data: data,
						original_id: item.id
					})
				end
			end
		ensure
			ActiveRecord::Base.record_timestamps = true
		end
	end
end
