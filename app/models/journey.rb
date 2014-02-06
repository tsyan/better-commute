require 'chronic'

class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes

	# defines origin_string in terms of something that exists in the database
	def origin_string
		origin_address
	end

	# defines origin_coordinates and origin_address from user input and stores it in the database
	def origin_string=(user_input)
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"

		origin_geocode = Rails.cache.fetch(["origin geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end

		lat = origin_geocode["geometry"]["location"]["lat"].to_s
		lon = origin_geocode["geometry"]["location"]["lng"].to_s

		self.origin_coordinates = lat + "," + lon

		formatted_address = origin_geocode["formatted_address"].chomp!(", USA")

		self.origin_address = formatted_address
	end

	# defines destination_string in terms of something that exists in the database
	def destination_string
		destination_address
	end

	# defines destination_coordinates and destination_address from user input and stores it in the database
	def destination_string=(user_input)
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"

		# destination_geocode = Rails.cache.fetch(["destination geocode", search_url], expires_in: 1.week) do
		# 	HTTParty.get(URI.encode(search_url))["results"][0]
		# end

		destination_geocode = HTTParty.get(URI.encode(search_url))["results"][0]

		lat = destination_geocode["geometry"]["location"]["lat"].to_s
		lon = destination_geocode["geometry"]["location"]["lng"].to_s

		self.destination_coordinates = lat + "," + lon

		formatted_address = destination_geocode["formatted_address"].chomp!(", USA")

		self.destination_address = formatted_address
	end

	# defines time_must_arrive_by_string in terms of something that exists in the database
	def time_must_arrive_by_string
		time_must_arrive_by.to_s
	end

	# defines time_must_arrive_by from user input and stores it in the database
	def time_must_arrive_by_string=(user_input)
		self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.now)
	end

end

