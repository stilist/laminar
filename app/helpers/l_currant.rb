module LCurrant
	require "find"
	require "json"

	class Parser
		@@errors = []

		# http://www.manamplified.org/archives/2006/10/url-regex-pattern.html
		# tags are documented in `rc format.mdown`
		url_pattern = /([A-Za-z][A-Za-z0-9+.-]{1,120}:[A-Za-z0-9\/](([A-Za-z0-9$_.+!*,;\/?:@&~=-])|%[A-Fa-f0-9]{2}){1,333}(#([a-zA-Z0-9][a-zA-Z0-9$_.+!*,;\/?:@&~=%-]{0,1000}))?)/u

		iso_year = /[\+-]?\d{5}/u
		iso_month = /(0[1-9]|1[0-2])/u
		iso_day = /([0-2][0-9]|3[0-1])/u
		iso_fraction = /([\.,]\d+)?/u
		iso_hour = /([0-1][0-9]|2[0-4])#{iso_fraction}/u
		iso_minute = /[0-5][0-9]#{iso_fraction}/u
		iso_second = /[0-5][0-9]#{iso_fraction}/u
		iso_timezone = /(Z|[\+-](#{iso_hour}:#{iso_minute}|#{iso_hour}#{iso_minute}|#{iso_hour}))/u
		iso_cal_date = /#{iso_year}(-#{iso_month}-#{iso_day}|#{iso_month}#{iso_day}|-#{iso_month})/u
		iso_time = /(#{iso_hour}:#{iso_minute}(:#{iso_second})?|#{iso_hour}#{iso_minute}(#{iso_second})?|#{iso_hour})/u
		iso_datetime = /#{iso_cal_date}T#{iso_time}(#{iso_timezone})?/u

		@@valid_metatags = {
			"AUTHOR" => { pat: /\w+/u },
			"BOOKMARK" => { pat: url_pattern },
			"COPYRIGHT" => { pat: /\w+/u },
			"GEOLOCATION" => { pat: /(ADDR .+|GPS [A-Z0-9-]+ (-)?\d{1,3}(.\d{0,})?, (-)?\d{1,3}(.\d{0,})?)/u },
			"KEYWORDS" => { pat: /\w+( \w*)*(, \w+( \w+)*)*/u },
			"LICENSE" => { pat: /\w+/u },
			"LINK" => { pat: url_pattern },
			"MEDIUM" => { pat: /.+/u },
			"PERMALINK" => { req: true, pat: url_pattern },
			"PRIVATE" => { pat: /(true|false)/ },
			"PUBLISHED" => { req: true, pat: /#{iso_datetime}/u },
			"SOURCE" => { pat: /.+/u },
			"SOURCEURI" => { pat: url_pattern },
			"TITLE" => { req: true, pat: /.+/u },
			"UPDATED" => { req: true, pat: /#{iso_datetime}/u }
		}

		def load_files paths=[]
			entry_paths = []
			file_list = []
			paths.each { |p| entry_paths << File.expand_path(p) }

			if entry_paths.empty?
				@@errors << "Please specify a file or directory to validate"
			else
				entry_paths.each { |path|
					Find.find(path) { |f| file_list << f }
				}
			end

			file_list
		end

		def parse_entry entry=""
			out = {}
			errors = []

			document = entry.split "--\n"

			out["body"] = document[1]
			errors << :missing_body if out["body"].nil?

			unless out["body"].nil?
				metatags = document[0]
				tags = parse_tags metatags
				errors << :missing_tags unless has_required_tags?(tags)
				tags.each do |name, data|
					if valid_tag?(name, data) == true
						out[name.downcase] = data
					else
						errors << "invalid_#{name.downcase}".to_sym
					end
				end
			end

			return out, errors
		end

		def parse_tags metatags=""
			tags = {}

			metatags.each_line do |line|
				tag = line.split ":"
				name = tag[0]

				# handle tag data with colons
				data = tag[1..-1].join(":").strip

				# ignore duplicated `name`
				tags[name] = data unless tags[name]
			end

			tags
		end

		def has_required_tags? tags={}
			missing = []

			required_tags = @@valid_metatags.map { |k,v| k if v[:req] }.compact
			required_tags.each { |tag| missing << tag unless tags[tag] }

			missing
		end

		def valid_tag? name, data
			error = nil

			if @@valid_metatags[name]
				match = (data =~ @@valid_metatags[name][:pat])
				error = :invalid_data unless match
			else
				error = :invalid_tag
			end

			error || true
		end

		@@errors = []

		def parse_files paths=[]
			out = []

			file_list = load_files(paths).flatten

			file_list.each do |file|
				errors = []

				# skip `.DS_Store`
				next if File.extname(file) == ""

				if File.file? file
					puts "-----> #{file}"

					if File.extname(file) =~ /\.(mdown|rc)/
						begin
							entry = IO.read file

							raw_data, parse_errors = parse_entry entry
							data = {
								"created_at" => raw_data["published"],
								"updated_at" => raw_data["published"],
								"data" => raw_data,
								"is_private" => true,
								"original_id" => File.basename(file)
							}
							data["url"] = raw_data["permalink"] if raw_data["permalink"]
							out << data if parse_errors.empty?

							errors << parse_errors
						rescue => e
							puts "       Parse error: #{e}"
							errors << :invalid_file
						end
					else
						errors << :unknown_type
					end

					puts "       errors: #{errors.flatten}" unless errors.flatten.empty?
				end
			end

			out
		end
	end

	def self.process_data paths=[]
		parser = Parser.new
		parser.parse_files [paths]
	end
end
