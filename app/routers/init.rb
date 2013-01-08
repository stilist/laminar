routers = %w(main)
routers.each { |router| require_relative router }
