# uh ok there activesupport
module LWikipedium
	def self.get_edits
		abort "       Please specify WIKIPEDIA_USER" unless ENV["WIKIPEDIA_USER"]

		url = "http://en.wikipedia.org/w/api.php?action=query&list=usercontribs&ucuser=#{ENV["WIKIPEDIA_USER"]}&uclimit=500&ucdir=newer&format=json"
		res = JSON.parse open(url, "User-Agent" => "Laminar/1.1").read
		data = res["query"]["usercontribs"]
		items = self.process_data data

		Laminar.add_items "wikipedia", "edit", items
	end

	private

	def self.process_data raw_items=[]
		raw_items.map do |item|
			time = DateTime.parse(item["timestamp"]).iso8601

			{
				"created_at" => time,
				"updated_at" => time,
				"data" => item,
				"url" => "http://en.wikipedia.org/w/index.php?diff=#{item["revid"]}&oldid=#{item["parentid"]}",
				"original_id" => "#{item["pageid"]}-#{item["revid"]}"
			}
		end
	end
end
