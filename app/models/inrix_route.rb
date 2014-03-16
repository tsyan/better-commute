class InrixRoute
	include HTTParty

	attr_accessor :route_id, :first_departure_time, :directions

	def initialize(origin_coordinates, destination_coordinates, time_must_arrive_by)

		@token = Token.new
		@origin_coordinates = origin_coordinates
		@destination_coordinates = destination_coordinates
		@time_must_arrive_by = time_must_arrive_by
		@count = 8 # to be used later in get_all_routes url
		@interval = 15 # to be used later in get_all_routes url
		@route_id = get_route_id # private method
		@first_departure_time = get_first_departure_time # private method
		@directions = get_directions

	end

	def get_directions
		directions = @find_route_response["Route"]["Maneuvers"]["Maneuver"].map do |turn| # directions is an array
			turn["text"].squish.gsub(/go .+ for /, 'go ') # make directions easier to read
		end rescue nil
	end

	def get_all_routes
		travel_times_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&DepartureTime=#{@first_departure_time.iso8601}&TravelTimeCount=#{@count}&TravelTimeInterval=#{@interval}"
		all_routes = HTTParty.get(URI.encode(travel_times_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"] rescue nil
	end

	private

	def get_route_id
		find_route_url = "#{@token.api_server}?Action=FindRoute&Token=#{@token.value}&wp_1=#{@origin_coordinates}&wp_2=#{@destination_coordinates}&ArrivalTime=#{@time_must_arrive_by.iso8601}&UseTraffic=false"
		@find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"] rescue nil
		route_id = @find_route_response["Route"]["id"] rescue nil
	end

	def get_first_departure_time
		departure_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&ArrivalTime=#{@time_must_arrive_by.iso8601}&TravelTimeCount=1&TravelTimeInterval=1"
		last_departure_travel_time = HTTParty.get(URI.encode(departure_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]["travelTimeMinutes"].to_i rescue nil
		return if !last_departure_travel_time
		first_departure_time = (@time_must_arrive_by - 60*last_departure_travel_time) - ((@count-1) * 60*@interval)
		# make sure first departure is in the future (if it's not, add the correct number of days)
		if first_departure_time - Time.now < 0
			first_departure_time + 86400 * ((first_departure_time - Time.now)/(-86400)).ceil
		else
			first_departure_time
		end
	end

end
