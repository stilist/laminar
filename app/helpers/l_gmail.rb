module LGmail
	def self.client
		@client ||= Gmail.new(ENV["GMAIL_USER"], ENV["GMAIL_PASSWORD"])
	end

	def self.get_received backfill=false
		self.get_data "[Gmail]/All Mail", "received", backfill
	end

	def self.get_sent backfill=false
		self.get_data "[Gmail]/Sent Mail", "sent", backfill
	end

	def self.body message
		if message.html_part
			message.html_part.body
		elsif message.text_part
			message.text_part.body
		else
			message.raw_source
		end
	end

	private

	def self.get_data mailbox, activity_type, backfill=false
		client = self.client

		yesterday = Time.now - (60 * 60 * 24)
		opts = backfill ? {} : { after: yesterday }
		data = client.mailbox(mailbox).emails opts

		puts "-----> #{mailbox}: #{data.length} messages"

		grouped = data.each_slice(100).to_a
		grouped.each do |group|
			items = self.process_data(group).compact
			Laminar.add_items "gmail", activity_type, items
		end
	ensure
		client.logout
	end

	def self.process_data raw_items=[]
		ids = Activity.unscoped.where(source: "gmail").select("original_id").
				map(&:original_id)

		raw_items.map do |item|
			debug = "       #{item.uid}: #{item.message.subject}"

			existing = ids.index item.uid.to_s
			debug << " (skipped)" if existing
			puts debug
			next if existing

			time = item.message.date
			{
				"created_at" => time,
				"updated_at" => time,
				"data" => { "raw_message" => self.raw_message(item.message) },
				"is_private" => true,
				"original_id" => item.uid.to_s
			}
		end
	end

	def self.raw_message message
		message.encoded
	rescue
		message.raw_source
	end
end
