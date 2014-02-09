class InrixRoute
	include HTTParty

	def initialize(token, origin_coordinates, destination_coordinates, time_must_arrive_by, journey_id)

		@token = token
		@origin_coordinates = origin_coordinates
		@destination_coordinates = destination_coordinates
		@time_must_arrive_by = time_must_arrive_by
		@count = 8 # to be used later in GetRouteTravelTimes url
		@interval = 15 # to be used later in GetRouteTravelTimes url
		@journey_id = journey_id

	end

	def id
		find_route_url = "#{@token.api_server}?Action=FindRoute&Token=#{@token.value}&wp_1=#{@origin_coordinates}&wp_2=#{@destination_coordinates}&ArrivalTime=#{@time_must_arrive_by.iso8601}&UseTraffic=false"

		@find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"]

		@route_id = @find_route_response["Route"]["id"]
	end

	def directions
		@find_route_response["Route"]["Maneuvers"]["Maneuver"].map do |turn| # directions is an array
			turn["text"].squish.gsub(/go .+ for /, 'go ') # make directions easier to read
		end
	end

	def first_departure_time

		departure_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&ArrivalTime=#{@time_must_arrive_by.iso8601}&TravelTimeCount=1&TravelTimeInterval=1"

		@departure_response = HTTParty.get(URI.encode(departure_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]

		last_departure_travel_time = @departure_response["travelTimeMinutes"].to_i

		@first_departure_time = (@time_must_arrive_by - 60*last_departure_travel_time) - ((@count-1) * 60*@interval)

	end

	def travel_times

		travel_times_url = "#{@token.api_server}?Action=GetRouteTravelTimes&Token=#{@token.value}&RouteID=#{@route_id}&DepartureTime=#{@first_departure_time.iso8601}&TravelTimeCount=#{@count}&TravelTimeInterval=#{@interval}"

		@travel_times_response = HTTParty.get(URI.encode(travel_times_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]

		@travel_times = []

		@travel_times_response.each do |route|
			travel_time = route["travelTimeMinutes"]
			@travel_times << travel_time
		end

		return @travel_times

	end

	def departure_times

		@departure_times = []

		@travel_times_response.each do |route|
			departure_time = route["departureTime"]
			@departure_times << departure_time
		end

		return @departure_times

	end

	def arrival_times

		@arrival_times = []

		@travel_time_in_seconds = @travel_times.map do |travel_time|
			60*travel_time.to_i
		end

		@departure_times.zip @travel_time_in_seconds

		@departure_times.zip(@travel_time_in_seconds).each do |departure_time, travel_time_in_seconds|
			arrival_time = Time.parse(departure_time).localtime + 60*travel_time_in_seconds.to_i
			@arrival_times << arrival_time
		end

		return @arrival_times

	end


end
