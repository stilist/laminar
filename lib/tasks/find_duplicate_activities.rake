task :find_duplicate_activities do
	known = {}
	dups = []

	begin
		ActiveRecord::Base.record_timestamps = false
		Activity.all.each do |a|
			next unless a.original_id

			name = [a.source, a.activity_type, a.original_id.to_s].join "-"

			if known[name]
				puts "  * #{a.id}: #{name} (duplicate of #{known[name]})"
				dups << a.id
			else
				known[name] = a.id
			end
		end
	ensure
		ActiveRecord::Base.record_timestamps = true
	end

	puts
	puts "*** #{dups.length} duplicates"
	puts
	puts dups.inspect
end