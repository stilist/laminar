routers = %w(main activities sources)
routers.each { |router| require_relative router }
