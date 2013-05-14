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
end
