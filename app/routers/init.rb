routers = %w(main activities authorize sources)
routers.each { |router| require_relative router }
