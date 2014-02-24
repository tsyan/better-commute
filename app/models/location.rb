class Location
	include HTTParty

	attr_reader :geocode, :address, :coordinates

	def initialize(user_input)
		@user_input = user_input
		@geocode = get_geocode # private method
		@address = get_address
		@coordinates = get_coordinates
	end

	def get_address
		return if @geocode.blank?
		formatted_address = @geocode["formatted_address"].chomp!(", USA")
	end

	def get_coordinates
		return if @geocode.blank?
		lat = @geocode["geometry"]["location"]["lat"].to_s
		lon = @geocode["geometry"]["location"]["lng"].to_s
		origin_coordinates = lat + "," + lon
	end

	private

	def get_geocode
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"
		geocode = Rails.cache.fetch(["origin geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end
		return if geocode.blank?
		geocode
	end

end
