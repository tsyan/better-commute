class Location

	attr_accessor :geocode, :address, :coordinates

	def initialize(user_input)
		@user_input = user_input
		@geocode = get_geocode rescue nil # private method
		@address = get_address rescue nil
		@coordinates = get_coordinates rescue nil
	end

	private

	def get_geocode
		search_url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{@user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"
		geocode = Rails.cache.fetch(["origin geocode", search_url], expires_in: 1.week) do
			HTTParty.get(URI.encode(search_url))["results"][0]
		end
	end

	def get_address # returns nil if address is outside of USA or Canada
		if @geocode["formatted_address"].match(/USA|CA|Canada/)
			formatted_address = @geocode["formatted_address"].gsub(/, USA/,"")
		end
	end

	def get_coordinates
		lat = @geocode["geometry"]["location"]["lat"].to_s
		lon = @geocode["geometry"]["location"]["lng"].to_s
		origin_coordinates = lat + "," + lon
	end

end
