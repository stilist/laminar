routers = %w(main activities authorize dates sources)
routers.each { |router| require_relative router }
