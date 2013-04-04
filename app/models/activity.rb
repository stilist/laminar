# encoding: utf-8

class Activity < ActiveRecord::Base
	default_scope where(is_private: false).
			order("activities.updated_at DESC, activities.id DESC")
	serialize :data, ActiveRecord::Coders::Hstore

	# will_paginate
	self.per_page = 100

	def for_json recurse=true
		data = self.attributes

		# if recurse
		# 	data.delete "location_id"
		# 	data.delete "user_id"

		# 	data["location"] = self.location.for_json(false)
		# 	data["place"] = self.location.place.for_json(false)
		# 	data["user"] = self.user.for_json(false)
		# else
		# 	data["place_id"] = self.location.place_id
		# end

		data
	end

	def title ; @title ||= open_graph[:title] end
	def description ; @description ||= open_graph[:description] end

	private

	def h text
		Rack::Utils.escape_html text
	end

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

				user = data["owner"]
				username = user["realname"].empty? ? user["username"] : user["realname"]
				description = "favorited #{h username}’s #{media_type} ‘#{h data["title"]["_content"]}’"
			else
				title = "posted a #{media_type}"

				description = "posted the #{media_type} ‘#{h data["title"]}’"
				description << ": ‘#{data["description"]}’" unless data["description"].empty?
			end
		when "netflix"
			# TODO TV shows
			title = "reviewed a movie"

			description = "reviewed #{eval(data["title"])[:attributes][:regular]}"
			description << "(#{data["release_year"]}): #{data["user_rating"].to_i} stars"
		when "pinboard"
			title = "bookmarked a URL"

			description = "bookmarked"
			description << (data["description"].empty? ? self.url : data["description"])
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
			description = "#{title}: #{Twttr::text data, false}"
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
