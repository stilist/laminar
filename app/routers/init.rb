routers = %w(main activities)
routers.each { |router| require_relative router }
