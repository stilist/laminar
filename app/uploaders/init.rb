require "carrierwave/processing/rmagick"

uploaders = %w()
uploaders.each { |uploader| require_relative uploader }
