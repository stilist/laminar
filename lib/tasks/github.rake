namespace :github do
	task :authorize do
		puts "Open this URL in your browser to authorize Laminar:"
		puts LGithub.client.authorize_url(redirect_uri: ENV["GITHUB_AUTHORIZE_URL"],
				scope: "repo")
	end

	task :activity do ; LGithub.get_activity end
	task :backfill_activity do ; LGithub.get_activity true end
end
