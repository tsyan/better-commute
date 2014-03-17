class InrixRoute

	attr_accessor :route_id, :first_departure_time, :directions, :time_must_arrive_by

	def initialize(origin_coordinates, destination_coordinates, time_must_arrive_by)

		@token = Token.new rescue nil
		@origin_coordinates = origin_coordinates
		@destination_coordinates = destination_coordinates
		@time_must_arrive_by = time_must_arrive_by
		@count = 8 # to be used later in get_all_routes url
		@interval = 15 # to be used later in get_all_routes url
		@route_id = get_route_id rescue nil # private method
		@first_departure_time = get_first_departure_time rescue nil # private method
		@directions = get_directions rescue nil

	end

	def get_directions
		directions = @find_route_response["Route"]["Maneuvers"]["Maneuver"].map do |turn| # directions is an array
			turn["text"].squish.gsub(/go .+ for /, 'go ') # make directions easier to read
		end
	end

	def get_all_routes
		travel_times_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&DepartureTime=#{@first_departure_time.iso8601}&TravelTimeCount=#{@count}&TravelTimeInterval=#{@interval}"
		all_routes = HTTParty.get(URI.encode(travel_times_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]
	end

	private

	def get_route_id
		find_route_url = "#{@token.api_server}?Action=FindRoute&Token=#{@token.value}&wp_1=#{@origin_coordinates}&wp_2=#{@destination_coordinates}&ArrivalTime=#{@time_must_arrive_by.iso8601}&UseTraffic=false"
		@find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"]
		route_id = @find_route_response["Route"]["id"]
	end

	def get_first_departure_time
		departure_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&ArrivalTime=#{@time_must_arrive_by.iso8601}&TravelTimeCount=1&TravelTimeInterval=1"
		last_departure_travel_time = HTTParty.get(URI.encode(departure_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]["travelTimeMinutes"].to_i

		return if last_departure_travel_time == 0 # if route has closures
		first_departure_time = (@time_must_arrive_by - 60*last_departure_travel_time) - ((@count-1) * 60*@interval)

		# make sure first departure and arrival time are in the future (if not, add the correct number of days)
		if first_departure_time - Time.now < 0
			extra_time = 86400 * ((first_departure_time - Time.now)/(-86400)).ceil # is 0 if no extra days are needed
			first_departure_time = first_departure_time + extra_time
			@time_must_arrive_by = @time_must_arrive_by + extra_time
		end

		first_departure_time
	end

end
