class InrixRoute

	attr_accessor :route_id, :directions, :first_departure_time, :time_must_arrive_by, :time_can_leave_at, :all_routes

	def initialize(origin_coordinates, destination_coordinates, time_must_arrive_by, time_can_leave_at)

		@token = Token.new rescue nil
		@origin_coordinates = origin_coordinates
		@destination_coordinates = destination_coordinates
		@count = 8 # to be used later in get_all_routes url
		@interval = 15 # to be used later in get_all_routes url
		@route_id = get_route_id rescue nil # private method
		@travel_time = get_travel_time rescue nil # private method
		@directions = get_directions rescue nil # private method

		if time_must_arrive_by.present?
			@time_specifier = "ArrivalTime=#{time_must_arrive_by.iso8601}"
			@time_must_arrive_by = time_must_arrive_by
			@first_departure_time = get_first_departure_time  # private method
		elsif time_can_leave_at.present?
			@time_specifier = "DepartureTime=#{time_can_leave_at.iso8601}"
			@first_departure_time = time_can_leave_at
		end

		@all_routes = get_all_routes rescue nil # private method

	end

	private

	def get_route_id
		find_route_url = "#{@token.api_server}?Action=FindRoute&Token=#{@token.value}&wp_1=#{@origin_coordinates}&wp_2=#{@destination_coordinates}&#{@time_specifier}&UseTraffic=false"
		@find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"]
		route_id = @find_route_response["Route"]["id"]
	end

	def get_travel_time
		travel_time = @find_route_response["Route"]["travelTimeMinutes"].to_i
	end

	def get_directions
		directions = @find_route_response["Route"]["Maneuvers"]["Maneuver"].map do |turn| # directions is an array
			turn["text"].squish.gsub(/go .+ for /, 'go ') # make directions easier to read
		end
	end

	def get_first_departure_time
		return if @travel_time == 0 # if route has closures

		first_departure_time = (@time_must_arrive_by - 60*@travel_time) - ((@count-1) * 60*@interval)

		# make sure first departure and arrival time are in the future (if not, add the correct number of days)
		if first_departure_time - Time.now < 0
			extra_time = 86400 * ((first_departure_time - Time.now)/(-86400)).ceil # is 0 if no extra days are needed
			first_departure_time = first_departure_time + extra_time
			@time_must_arrive_by = @time_must_arrive_by + extra_time
		end

		first_departure_time
	end

	def get_all_routes
		travel_times_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&DepartureTime=#{@first_departure_time.iso8601}&TravelTimeCount=#{@count}&TravelTimeInterval=#{@interval}"
		all_routes = HTTParty.get(URI.encode(travel_times_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]
	end

end
