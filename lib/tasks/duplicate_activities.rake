namespace :duplicate_activities do
	task :find do
		dups = find_dups

		puts
		puts "*** found #{dups.length} duplicates"
		puts
		puts dups.inspect
	end

	task :remove do
		dups = find_dups

		puts "*** removing #{dups.length} duplicates"

		dups.each_slice(100) { |ids| Activity.unscoped.where(id: ids).delete_all }
	end

	def find_dups
		known = {}
		dups = []

		Activity.unscoped.select("id, source, activity_type, original_id").all.each do |a|
			next unless a.original_id

			name = [a.source, a.activity_type, a.original_id.to_s].join "-"

			if known[name]
				puts "  * #{a.id}: #{name} (duplicate of #{known[name]})"
				dups << a.id
			else
				known[name] = a.id
			end
		end

		dups
	end
end
