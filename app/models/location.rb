class Location
	include HTTParty

	def initialize(user_input)
		@user_input = user_input
	end

	def get_origin_address
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"

		@origin_geocode = Rails.cache.fetch(["origin geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end

		return if @origin_geocode.blank?

		formatted_address = @origin_geocode["formatted_address"].chomp!(", USA")
	end

	def get_origin_coordinates
		lat = @origin_geocode["geometry"]["location"]["lat"].to_s
		lon = @origin_geocode["geometry"]["location"]["lng"].to_s

		origin_coordinates = lat + "," + lon
	end

	def get_destination_address
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"

		@destination_geocode = Rails.cache.fetch(["destination geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end

		return if @destination_geocode.blank?

		formatted_address = @destination_geocode["formatted_address"].chomp!(", USA")
	end

	def get_destination_coordinates
		lat = @destination_geocode["geometry"]["location"]["lat"].to_s
		lon = @destination_geocode["geometry"]["location"]["lng"].to_s

		destination_coordinates = lat + "," + lon
	end




end
