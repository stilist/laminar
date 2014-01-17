# encoding: utf-8

class Activity < ActiveRecord::Base
	serialize :data, JSON

	has_many :geolocations

	default_scope { order("activities.updated_at DESC, activities.id DESC") }

	serialize :data, ActiveRecord::Coders::Hstore

	after_save :parse_locations!

	# will_paginate
	self.per_page = 50

	def for_json recurse=true
		out = self.attributes

		out["data"] = YAML.load(self.parsed_data) if self.parsed_data

		out
	end

	def title ; @title ||= open_graph[:title] end
	def description ; @description ||= open_graph[:description] end

	def parse_data!
		parsed = Activity.parse_data self.source, self.activity_type, self.data

		ActiveRecord::Base.record_timestamps = false
		self.parsed_data = parsed
		self.save
		ActiveRecord::Base.record_timestamps = true
	end

	def self.parse_data source, activity_type, data
		helper = Laminar.helper source

		if helper.respond_to? :parse_activity
			helper.parse_activity data, activity_type
		else
			nil
		end
	end

	def parse_locations!
		locations = Activity.parse_locations self.source, self.data

		if locations
			locations = [locations] unless locations.is_a? Array
			processed = locations.map { |l| Geolocation.create l }
		else
			processed = nil
		end

		self.geolocations = processed
	end

	def self.parse_locations source, data
		helper = Laminar.helper source

		if data && helper.respond_to?(:parse_locations)
			helper.parse_locations data
		else
			nil
		end
	end

	private

	# This is kind of a monster
	def open_graph
		return { title: @title, description: @description } if @title && @description

		title = description = ""
		data = self.data
		case self.source
		when "flickr"
			media_type = (data.has_key? "video") ? "video" : "photo"
			if self.activity_type == "favorite"
				title = "favorited a #{media_type}"

				user = eval(data["photo"])["owner"]
				username = user["realname"].empty? ? user["username"] : user["realname"]
				description = "favorited #{Laminar.h username}’s #{media_type} ‘#{Laminar.h data["title"]["_content"]}’"
			else
				title = "posted a #{media_type}"

				description = "posted the #{media_type} ‘#{Laminar.h data["title"]}’"
				description << ": ‘#{data["description"]}’" unless data["description"].empty?
			end
		when "netflix"
			# TODO TV shows
			title = "reviewed a movie"

			description = "reviewed #{eval(data["title"])[:attributes][:regular]}"
			description << "(#{data["release_year"]}): #{data["user_rating"].to_i} stars"
		when "openpaths"
			title = "was triangulated"

			lat = data["lat"].to_f.round 2
			lng = data["lon"].to_f.round 2

			description = "was at #{lat}° N, #{lng}° W"
		when "pinboard"
			title = "bookmarked a URL"

			description = "bookmarked"
			description << (data["description"].empty? ? self.url : data["description"])
		when "sleep_cycle"
			title = "recorded a sleep session"
			time = data["duration"].to_f / 60 / 60
			description = "#{time} hours, #{data["quality"].to_f / 10.0}/10"
		when "twitter"
			if self.activity_type == "favorite"
				user = data["user"].is_a?(String) ? eval(data["user"]) : data["user"]
				title = "favorited #{user["name"]}’s tweet"
			else
				if data["retweeted_status"]
					retweet = eval(data["retweeted_status"])
					title = "retweeted #{retweet["user"]["name"]}"
				else
					title = "posted a tweet"
				end
			end
			description = "#{title}: #{LTwitter::text data, false}"
		when "vimeo"
			if self.activity_type == "like"
				title = "liked user’s video"
			elsif self.activity_type == "video"
				title = "posted a video"
			end
			description = "#{title}: #{data["title"]}"
		# fallback
		else
			vowels = %w(a e i o u)
			if vowels.include? self.activity_type[-1]
				verb = "#{self.activity_type}d"
			else
				verb = "#{self.activity_type}ed"
			end

			# Intentionally leave `description` blank
			title = "#{verb} on #{self.source}"
		end

		title = "#{title[0..69]}…" if title.length > 70
		description = "#{description[0..199]}…" if description.length > 200
		{ title: title, description: description }
	end
end
