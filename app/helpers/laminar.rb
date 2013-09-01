module Laminar
	@@conditions = {
		sunny: 80,
		mostlysunny: 73,
		partlysunny: 70,
		clear: 63,
		partlycloudy: 60,
		mostlycloudy: 55,
		cloudy: 50,
		fog: 45,
		hazy: 40,
		rain: 40,
		tstorms: 37,
		chancetstorms: 35,
		chancerain: 30,
		chanceflurries: 20,
		chancesnow: 17,
		flurries: 15,
		snow: 10,
		sleet: 7,
		chancesleet: 10,
		unknown: 0
	}.freeze

	def self.activities params
		key = params[:private_data_key]
		include_private = key && key == ENV["PRIVATE_DATA_KEY"]

		out = include_private ? Activity : Activity.where(is_private: false)
		out.page params[:page]
	end

	def self.source_template source="", items=[]
		if !source.blank? && App.source_templates[source]
			App.source_templates[source].to_sym
		else
			""
		end
	end

	def markdown text=""
		markdown = Redcarpet::Markdown.new Redcarpet::Render::HTML, autolink: true

		# Hack: Redcarpet specifically refuses to process Markdown inside of
		# `<figure>` tags, though absolutely any other tag seems to be fine.
		temp_text = text.gsub(/<(\/?figure)>/, "<\\1_temp>")
		out = markdown.render temp_text
		out.gsub /_temp>/, ">"
	end

	def h text="" ; Rack::Utils.escape_html(text) end

	def nl2br text="" ; text.gsub(/(\r\n|\r|\n)/, "<br>") end

	def item_classes data
		classes = %w(hentry hnews)
		classes << "type-#{data["activity_type"]} source-#{data["source"]}"
		classes << "full_view" if data["extras"]["full_view"]
		classes << "hreview" if data["activity_type"] == "review"
		classes.join " "
	end

	def item_hsl data, as_style=true
		observations = data["extras"] ? data["extras"]["observations"] : nil

		hsl = calculate_hsl data, observations

		if as_style
			lum = hsl[:luminance]
			# For the upper and lower third it's enough to use the inverse. For the
			# remaining third there's not enough contrast, so cheat a bit.
			counter_lum = 100 - lum
			if (33..66).include? counter_lum
				counter_lum = (counter_lum > 50) ? (counter_lum + 25) : (counter_lum - 25)
			end

			"background-color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{lum}%);
			color:hsl(#{hsl[:hue]}, #{hsl[:saturation]}%, #{counter_lum}%);"
		else
			[hsl[:hue], (hsl[:saturation] / 100.0), (hsl[:luminance] / 100.0)]
		end
	end

	def self.sym2s h
		# http://stackoverflow.com/a/8380073/672403
		Hash === h ? Hash[h.map { |k, v| [k.to_s, Laminar.sym2s(v)] }] : h
	end

	def self.add_items source="", activity_type="", items=[]
		abort "       Laminar.add_items was called with a blank source" if source.blank?
		abort "       Laminar.add_items was called with a blank activity_type" if activity_type.blank?

		total = items.length

		puts
		puts "-----> #{source}: processing #{total} #{activity_type} item(s)"

		if total > 0
			ids = Activity.unscoped.where(source: source).
					where(activity_type: activity_type).select("original_id").
					map { |activity| activity.original_id }

			begin
				ActiveRecord::Base.record_timestamps = false
				items.each_with_index do |item, idx|
					puts "       #{source}/#{activity_type}: #{item["original_id"]} [#{idx + 1}/#{total}]"

					existing = ids.index item["original_id"]

					unless existing
						item.merge!({
							source: source,
							activity_type: activity_type
						})

						Activity.create item
					end
				end
			rescue => e
				puts "       Failed to add data:"
				puts e
			ensure
				ActiveRecord::Base.record_timestamps = true
			end
		end
	end

	def self.get_static_data uri=""
		if uri.blank?
			puts "       Laminar.get_static_data was called with a blank URI"
			abort
		end

		data = open(uri).read
		JSON.parse data
	rescue OpenURI::HTTPError => e
		puts "       Laminar.get_static_data was unable to fetch data"
		puts "       (called with: #{uri})"
		abort
	rescue => e
		abort e
	end

	def self.put_static_data filename="", data=[]
		if filename.blank?
			puts "       Laminar.put_static_data was called with a blank filename"
			abort
		end

		puts "       Uploading #{data.length} item(s) to #{filename}"

		storage = Fog::Storage.new({
			provider: ENV["FOG_PROVIDER"],
			aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
			aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]
		})

		directory = storage.directories.get ENV["FOG_DIRECTORY"]
		file = directory.files.get filename
		json = data.to_json

		if file
			file.body = json
			file.public = true
		else
			file = directory.files.create({
				key: filename,
				body: json,
				public: true
			})
		end

		file.save

		file
	rescue => e
		puts "       Failed to upload data:"
		puts e
	end

	# `time` is in seconds
	def self.adjust_core_data_timestamp time=0
		# Cocoa (and thus Core Data) epoch is midnight UTC on 1 January 2001
		time_base = DateTime.new 2001, 01, 01, 0, 0, 0

		Time.at(time_base.to_time + time).iso8601
	end

	def self.extract_binary_plist path
		# `Plist::parse_xml` is able to read files directly, but sometimes
		# complains about invalid UTF-8 sequences, a problem `plutil` doesn't
		# share.
		file = IO.popen ["plutil", "-convert", "xml1", "-o", "-", path]
		raw_data = file.read
		file.close

		Plist::parse_xml raw_data
	end

	private

	def calculate_hsl data, observations=nil
		date = data["created_at"]

		hue = [360, date.yday].min + 240
		hue = (hue > 360) ? (hue - 360) : hue

		wo = Weather::nearest_observation data["created_at"], observations
		saturation = wo ? (@@conditions[wo["data"]["icon"].to_sym] || 0) : 0

		# minutes...   [       through day       ]   [in day]
		pct_of_day = (((date.hour * 60) + date.min) / 1400.0) * 100
		# Peak at midday
		luminance = (pct_of_day > 50 ? (100 - pct_of_day) : pct_of_day).floor.abs

		{ hue: hue, saturation: saturation, luminance: luminance }
	end
end
