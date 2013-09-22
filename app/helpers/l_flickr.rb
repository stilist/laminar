module LFlickr
	@@base_delay = (60 * 60) / 3600 # 3600 requests/hour

	def self.initialize_client
		abort "       Please specify FLICKR_CLIENT_KEY" unless ENV["FLICKR_CLIENT_KEY"]
		abort "       Please specify FLICKR_CLIENT_SECRET" unless ENV["FLICKR_CLIENT_SECRET"]

		FlickRaw.api_key = ENV["FLICKR_API_KEY"]
		FlickRaw.shared_secret = ENV["FLICKR_API_SECRET"]

		flickr.access_token = ENV["FLICKR_CLIENT_KEY"]
		flickr.access_secret = ENV["FLICKR_CLIENT_SECRET"]

		@client ||= flickr
		@user ||= @client.test.login

		puts "*** Logged in as #{@user.username} (#{@user.id})"
	end

	def self.get_favorites backfill=false
		self.initialize_client

		total = flickr.favorites.getList(user_id: @user.id, per_page: 1)["total"].to_i
		per_page = 500 # max: 500
		pages = backfill ? (total / per_page.to_f).ceil : 1

		puts "       #{total} favorite(s)"

		items = []

		(1..pages).each_with_index do |page, p_idx|
			raw_items = flickr.favorites.getList({
				user_id: $user_id,
				per_page: per_page,
				page: page
			})

			raw_items.each_with_index do |raw_item, i_idx|
				n = (p_idx * per_page) + i_idx + 1
				puts "       #{raw_item["id"]} [#{n}/#{total}]"

				# clone `Response` object
				data = {}
				raw_item.to_hash.each { |k, v| data[k] = v }

				data["photo"] = flickr.photos.getInfo(photo_id: data["id"]).to_hash

				timestamp = Time.at(data["date_faved"].to_i).iso8601
				item = {
					"created_at" => timestamp,
					"updated_at" => timestamp,
					"is_private" => (data["ispublic"] != 1),
					"data" => data,
					"url" => self.photo_url(data),
					"original_id" => data["id"].to_s
				}
				items << item

				sleep @@base_delay * 2
			end

			sleep @@base_delay * 10
		end

		Laminar.add_items "flickr", "favorite", items
	end

	# helpers ###################################################################

	# http://www.flickr.com/services/api/misc.buddyicons.html
	def self.avatar_url data
		if data["iconfarm"] > 0
			"http://farm#{data["iconfarm"]}.staticflickr.com/#{data["iconserver"]}/buddyicons/#{data["nsid"]}.jpg"
		else
			"http://www.flickr.com/images/buddyicon.gif"
		end
	end

	def self.person_url data
		"http://www.flickr.com/photos/#{data["owner"]}"
	end

	def self.photo_url data
		# http://stackoverflow.com/a/3908411/672403
		owner = data["owner"]
		if owner.is_a?(String)
			# Catch serialized `Hash`
			person = owner[0] == "{" ? eval(data["owner"])["nsid"] : owner
		else
			person = data["owner"]["nsid"]
		end

		"http://www.flickr.com/photos/#{person}/#{data["id"]}/"
	end

	def self.photo_source_url data, size="o"
		data = eval(data) unless data.is_a? Hash
		secret = (size == "o") ? data["originalsecret"] : data["secret"]
		"http://farm#{data["farm"]}.staticflickr.com/#{data["server"]}/#{data["id"]}_#{secret}_#{size}.jpg"
	end
end
