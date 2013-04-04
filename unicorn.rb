worker_processes 1
timeout 30

before_fork do |server, worker|
	if defined?(ActiveRecord::Base)
		ActiveRecord::Base.connection.disconnect!
		puts "Disconnected from ActiveRecord"
	end
end

after_fork do |server, worker|
	if defined?(ActiveRecord::Base)
		ActiveRecord::Base.establish_connection
		puts "Connected to ActiveRecord"
	end
end
