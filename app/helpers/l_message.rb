# https://github.com/dustym/py-imlog/blob/master/imlog/imlog.py#L70

module LMessage
	def self.get_desktop_data
		data_path = File.expand_path "~/Library/Messages/Archive/"

		out = []

		Dir.chdir(data_path) do
			files = Dir.glob("**/*.ichat")

			puts "-----> Processing #{files.count} message logs"

			files.each_with_index do |path, idx|
				puts "       #{path} [#{idx}/#{files.count}]"

				data = self.process_file path

				if data && !data.empty?
					time = data["messages"].last["time"]

					item = {
						"created_at" => time,
						"updated_at" => time,
						"original_id" => path,
						"is_private" => true,
						"data" => data
					}

					out << item
				end
			end
		end

		out
	end

	private

	def self.get_account objects=[]
		account = nil

		objects.each do |object|
			if object.is_a?(Hash) && object.has_key?("ServiceLoginID")
				account = self.extract objects, object["ServiceLoginID"]

				break
			end
		end

		account
	end

	def self.get_service objects=[]
		service = nil

		objects.each do |object|
			if object.is_a?(Hash) && object.has_key?("ServiceName")
				service = self.extract objects, object["ServiceName"]

				break
			end
		end

		service
	end

	def self.extract objects=[], hash={}, offset=0
		objects[hash["CF$UID"] + offset] if hash.has_key? "CF$UID"
	end

	def self.extract_string data ; data.is_a?(Hash) ? data["NS.string"] : data end

	def self.process_file path
		file = IO.popen(["plutil", "-convert", "xml1", "-o", "-", path])
		raw_data = file.read
		file.close

		parsed = Plist::parse_xml raw_data
		objects = parsed["$objects"]

		account = self.get_account objects
		service = self.get_service objects

		correspondent = nil

		messages = objects.map do |object|
			message = {}

			if object.is_a?(Hash) && object.has_key?("MessageText")
				sender_id = self.extract objects, object["Sender"]

				if sender_id != "$null"
					sender = self.extract objects, sender_id["ID"]
					message["sender"] = self.extract_string sender

					correspondent ||= message["sender"] if message["sender"] != account

					if message["sender"].is_a? String
						text = self.extract objects, object["MessageText"], 1
						message["text"] = self.extract_string text

						secs = self.extract(objects, object["Time"])["NS.time"].to_i
						time = Laminar.adjust_core_data_timestamp secs

						message["time"] = time
					end
				end
			end

			message unless message.empty?
		end

		if messages && !messages.compact.empty?
			{
				"account" => account,
				"correspondent" => correspondent,
				"service" => service,
				"messages" => messages.compact
			}
		end
	end
end
