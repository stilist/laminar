module LGithub
	def self.client options={}
		defaults = {
			client_id: ENV["GITHUB_API_KEY"],
			client_secret: ENV["GITHUB_API_SECRET"]
		}
		@client ||= Github.new defaults.merge(options)
	end

	def self.commits_url payload
		commits = payload["commits"]

		if payload["size"] == 1
			sanitize_url(commits.first["url"])
		else
			sanitize_url(commits.first["url"]).split("commits")[0] + "compare/" +
					short_sha(payload["before"]) + "..." + short_sha(payload["head"])
		end
	end

	def self.sanitize_url url=""
		url.sub "https://api.github.com/repos", "//github.com"
	end

	def self.short_sha sha="" ; sha[0..6] end

	def self.repo_owner item
		if item["org"]
			eval(item["org"])["login"]
		else
			eval(item["repo"])["name"].split("/")[0]
		end
	end

	def self.get_activity backfill=false
		delay = (60 * 60) / 5000 # 5000 requests/hour

		abort "       Please specify GITHUB_CLIENT_KEY" unless ENV["GITHUB_CLIENT_KEY"]
		abort "       Please specify GITHUB_USER" unless ENV["GITHUB_USER"]

		gh = LGithub.client({ oauth_token: ENV["GITHUB_CLIENT_KEY"] })

		data = gh.activity.events.user_performed ENV["GITHUB_USER"]
		grouped_items = self.process_data data

		grouped_items.each { |type, items| Laminar.add_items "github", type, items }

		if backfill
			# Will fetch up to 300 items
			while data.has_next_page?
				data = items.next_page
				grouped_items = self.process_data data

				grouped_items.each { |type, items| Laminar.add_items "github", type, items }

				sleep delay
			end
		end
	end

	def self.process_data raw_items
		out = {}

		raw_items.each do |item|
			time = Time.parse item.created_at

			data = {}
			item.each { |k,v| data[k] = v.is_a?(Hashie::Mash) ? v.to_hash : v }

			public = item.public.is_a?(String) ? eval(item.public) : item.public

			out_item = {
				"created_at" => time,
				"updated_at" => time,
				"is_private" => !public,
				"data" => data,
				"url" => item.repo.url,
				"original_id" => item.id
			}

			activity_type = item.type.sub("Event", "").underscore
			if out.has_key? activity_type
				out[activity_type] << out_item
			else
				out[activity_type] = [out_item]
			end
		end

		out
	end
end
