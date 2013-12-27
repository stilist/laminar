module LCoinbase
	def self.get_transactions backfill=false
		# https://coinbase.com/docs/api/authentication#api_key
		abort "       Please specify COINBASE_API_KEY" unless ENV["COINBASE_API_KEY"]
		client = Coinbase::Client.new ENV["COINBASE_API_KEY"]

		_data = client.transactions
		total = _data["total_count"]
		pages = backfill ? _data["num_pages"] : 1

		puts "*** #{total} transactions"

		1.upto(pages).each_with_index do |page, p_idx|
			data = client.transactions page
			items = self.process_data data

			Laminar.add_items "coinbase", "transaction", items, { replace: true }

			sleep(5) if pages > 1
		end
	end

	private

	def self.process_data raw_items
		raw_items["transactions"].map do |raw_item|
			item = raw_item["transaction"]
			processed_item = item.to_hash

			time = Time.parse(item["created_at"]).iso8601

			# Note: the API also uses `amount["currency"]` as a key, but with a different
			# meaning.
			btc_amount = item.amount.format
			currency_amount = item.notes.match /(\d+\.\d+)/
			processed_item["amount"] = {
				"btc" => item.amount.format.to_f,
				"currency" => item.notes.match(/(\d+\.\d+)\./)[1].to_f
			}

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => processed_item,
				"original_id" => item["id"]
			}
		end
	end
end
