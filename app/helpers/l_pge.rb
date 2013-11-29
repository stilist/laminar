# encoding: UTF-8

module LPge
	def self.process_local_data
		require "csv"

		data = nil

		directory = File.expand_path "sources/pge"
		Dir.chdir(directory) do
			data = Dir.glob("*.csv").map { |path| self.preprocess_data open(path).readlines }
		end
		cleaned = data.flatten(1).compact
		sorted = cleaned.sort { |a,b| a[0] <=> b[0] }

		sorted.map do |row|
			date = row[0]
			time = date.to_time.iso8601

			{
				created_at: time,
				updated_at: time,
				original_id: date,
				data: { time_series: row[1] }
			}
		end
	end

	private

	def self.preprocess_data raw_data
		# data starts on line 14
		raw_data.drop(14).map do |row|
			# dates with no data are filled with `-` and get a `"Missing data …" row
			parsed_row = row.gsub(/["\r\n]/, "").gsub(/\-/, "0").split(/,/)
			next if parsed_row.length == 0 || row =~ /Missing data/

			date = parsed_row.delete_at 0
			parsed_date = Date.strptime date, "%m/%d/%Y"
			data = parsed_row.map { |column| column.to_i }

			[parsed_date, data]
		end
	end
end
