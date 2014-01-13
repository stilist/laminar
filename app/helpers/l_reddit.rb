module LReddit
	def self.client
		abort "       Please specify REDDIT_PASSWORD" unless ENV["REDDIT_PASSWORD"]
		abort "       Please specify REDDIT_USER" unless ENV["REDDIT_USER"]

		@client ||= RedditKit::Client.new ENV["REDDIT_USER"], ENV["REDDIT_PASSWORD"]
	end

	def self.get_all backfill=false
		types = %w(submitted comments liked disliked hidden saved)

		types.each do |type|
			self.send "get_#{type}".to_sym, backfill

			# rate limit: 2 second delay
			sleep (backfill ? 12 : 3)
		end
	end

	def self.get_comments backfill=false ; self.get_data :comments, backfill end
	def self.get_submitted backfill=false ; self.get_data :submitted, backfill end
	def self.get_liked backfill=false ; self.get_data :liked, backfill end
	def self.get_disliked backfill=false ; self.get_data :disliked, backfill end
	def self.get_hidden backfill=false ; self.get_data :hidden, backfill end
	def self.get_saved backfill=false ; self.get_data :saved, backfill end

	def self.media data={}
		if data["media"]
			CGI::unescapeHTML eval(data["secure_media_embed"])[:content]
		elsif data["thumbnail"] && data["thumbnail"] != "default"
			"<img src='#{data["thumbnail"]}'>"
		else
			""
		end
	end

	private

	def self.get_data type, backfill
		options = {
			category: type,
			limit: 100 # max: 100
		}
		data = self.client.my_content options
		items = self.process_data data.results, type
		Laminar.add_items "reddit", type, items

		if backfill
			while data.after
				data = self.client.my_content options.merge(after: data.after)
				items = self.process_data data.results, type
				Laminar.add_items "reddit", type, items

				sleep 3
			end
		end
	end

	def self.get_url item, type
		base = "http://www.reddit.com"

		fullname_id = ->(fullname) { fullname.match(/([a-z0-9]+)$/)[1] }

		path = case type
		when :comments
			parent_id = fullname_id.call item[:parent_id]
			# Need to have something between parent and item ids to link a specific
			# comment, but the API doesn’t include the thread’s slug. Happily, even
			# just `_` works.
			"/r/#{item[:subreddit]}/comments/#{parent_id}/_/#{item[:id]}"
		when :disliked, :liked, :hidden, :saved, :submitted
			item[:permalink]
		end

		"#{base}#{path}"
	end

	def self.process_data raw_items, type
		raw_items.map do |raw_item|
			item = raw_item.attributes

			# All I wanted was to parse a UNIX timestamp in a different timezone.
			fake_utc = Time.at item[:created_utc]
			local = fake_utc.utc.iso8601.gsub /Z$/, Time.now.zone
			time = DateTime.parse(local).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"is_private" => (type == :hidden),
				"url" => self.get_url(item, type),
				"original_id" => item[:id].to_s
			}
		end
	end
end
