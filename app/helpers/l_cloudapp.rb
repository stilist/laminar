module LCloudapp
	def self.get_drops backfill=false
		abort "       Please specify CLOUDAPP_PASSWORD" unless ENV["CLOUDAPP_PASSWORD"]
		abort "       Please specify CLOUDAPP_USER" unless ENV["CLOUDAPP_USER"]
		client = CloudApp::Client.new
		client.authenticate ENV["CLOUDAPP_USER"], ENV["CLOUDAPP_PASSWORD"]

		total = CloudApp::Account.stats[:items]
		per_page = 100 # max: ?
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "*** #{total} drop(s)"

		1.upto(pages).each_with_index do |page, p_idx|
			data = CloudApp::Drop.all({ page: page, per_page: per_page })
			items = self.process_data data

			Laminar.add_items "cloudapp", "drop", items, { replace: true }

			sleep(5) if page < pages
		end
	end

	private

	def self.process_data raw_items
		raw_items.map do |item|
			{
				"created_at" => item.created_at.iso8601,
				"updated_at" => item.updated_at.iso8601,
				"data" => item.data,
				"is_private" => item.private,
				"url" => item.remote_url,
				"original_id" => item.data["id"].to_s
			}
		end
	end
end
