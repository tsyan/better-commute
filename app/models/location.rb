class Location
	include HTTParty

	attr_reader :address, :coordinates

	def initialize(user_input)
		@user_input = user_input
		@address = get_address # private method
		@coordinates = get_coordinates # private method
	end

	private

	def get_address
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"
		@origin_geocode = Rails.cache.fetch(["origin geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end
		return if @origin_geocode.blank?
		formatted_address = @origin_geocode["formatted_address"].chomp!(", USA")
	end

	def get_coordinates
		return if @origin_geocode.blank?
		lat = @origin_geocode["geometry"]["location"]["lat"].to_s
		lon = @origin_geocode["geometry"]["location"]["lng"].to_s
		origin_coordinates = lat + "," + lon
	end

end
