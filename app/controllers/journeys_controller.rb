class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		# @user = User.new("Test") # later this should be an if-else-end statement, if user is logged in then set @user as User.find(id)
		@journey = Journey.new(journey_params)
		@journey.save

		token = Token.new

		# FindRoute

		find_route_url = "#{token.api_server}?Action=FindRoute&Token=#{token.value}&wp_1=#{@journey.origin_coordinates}&wp_2=#{@journey.destination_coordinates}&ArrivalTime=#{@journey.time_must_arrive_by.iso8601}&UseTraffic=false"
		find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"]

		find_route_id = find_route_response["Route"]["id"]

		directions = find_route_response["Route"]["Maneuvers"]["Maneuver"].map do |turn| # directions is an array
  		turn["text"].squish.gsub(/go .+ for /, 'go ') # make directions easier to read
		end

		# calculate last_departure_travel_time

		departure_url = "#{token.api_server}?Action=GetRouteTravelTimes&Token=#{token.value}&RouteID=#{find_route_id}&ArrivalTime=#{@journey.time_must_arrive_by.iso8601}&TravelTimeCount=1&TravelTimeInterval=1"

		departure_response = HTTParty.get(URI.encode(departure_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]

		last_departure_travel_time = departure_response["travelTimeMinutes"].to_i

		# GetRouteTravelTimes

		count = 8
		interval = 15
		first_departure_time = (@journey.time_must_arrive_by - 60*last_departure_travel_time) - ((count-1) * 60*interval)

		travel_times_url = "#{token.api_server}?Action=GetRouteTravelTimes&Token=#{token.value}&RouteID=#{find_route_id}&DepartureTime=#{first_departure_time.iso8601}&TravelTimeCount=#{count}&TravelTimeInterval=#{interval}"
		travel_times_response = HTTParty.get(URI.encode(travel_times_url))["Inrix"]["Trip"]["Route"]["TravelTimes"]["TravelTime"]

		travel_time_1 = travel_times_response[0]["travelTimeMinutes"]
		departure_time_1 = travel_times_response[0]["departureTime"]
		arrival_time_1 = Time.parse(departure_time_1).localtime + 60*travel_time_1.to_i

		travel_time_2 = travel_times_response[1]["travelTimeMinutes"]
		departure_time_2 = travel_times_response[1]["departureTime"]
		arrival_time_2 = Time.parse(departure_time_2).localtime + 60*travel_time_2.to_i

		travel_time_3 = travel_times_response[2]["travelTimeMinutes"]
		departure_time_3 = travel_times_response[2]["departureTime"]
		arrival_time_3 = Time.parse(departure_time_3).localtime + 60*travel_time_3.to_i

		travel_time_4 = travel_times_response[3]["travelTimeMinutes"]
		departure_time_4 = travel_times_response[3]["departureTime"]
		arrival_time_4 = Time.parse(departure_time_4).localtime + 60*travel_time_4.to_i

		travel_time_5 = travel_times_response[4]["travelTimeMinutes"]
		departure_time_5 = travel_times_response[4]["departureTime"]
		arrival_time_5 = Time.parse(departure_time_5).localtime + 60*travel_time_5.to_i

		travel_time_6 = travel_times_response[5]["travelTimeMinutes"]
		departure_time_6 = travel_times_response[5]["departureTime"]
		arrival_time_6 = Time.parse(departure_time_6).localtime + 60*travel_time_6.to_i

		travel_time_7 = travel_times_response[6]["travelTimeMinutes"]
		departure_time_7 = travel_times_response[6]["departureTime"]
		arrival_time_7 = Time.parse(departure_time_7).localtime + 60*travel_time_7.to_i

		travel_time_8 = travel_times_response[7]["travelTimeMinutes"]
		departure_time_8 = travel_times_response[7]["departureTime"]
		arrival_time_8 = Time.parse(departure_time_8).localtime + 60*travel_time_8.to_i

		# save the routes

		# only the first route has saved directions, but the directions are the same for all routes
		@route_1 = @journey.routes.new(departure_time: departure_time_1, arrival_time: arrival_time_1, travel_time: travel_time_1, directions: directions, journey_id: @journey.id)

		@route_2 = @journey.routes.new(departure_time: departure_time_2, arrival_time: arrival_time_2, travel_time: travel_time_2, journey_id: @journey.id)

		@route_3 = @journey.routes.new(departure_time: departure_time_3, arrival_time: arrival_time_3, travel_time: travel_time_3, journey_id: @journey.id)

		@route_4 = @journey.routes.new(departure_time: departure_time_4, arrival_time: arrival_time_4, travel_time: travel_time_4, journey_id: @journey.id)

		@route_5 = @journey.routes.new(departure_time: departure_time_5, arrival_time: arrival_time_5, travel_time: travel_time_5, journey_id: @journey.id)

		@route_6 = @journey.routes.new(departure_time: departure_time_6, arrival_time: arrival_time_6, travel_time: travel_time_6, journey_id: @journey.id)

		@route_7 = @journey.routes.new(departure_time: departure_time_7, arrival_time: arrival_time_7, travel_time: travel_time_7, journey_id: @journey.id)

		@route_8 = @journey.routes.new(departure_time: departure_time_8, arrival_time: arrival_time_8, travel_time: travel_time_8, journey_id: @journey.id)

		if @route_1.save && @route_2.save && @route_3.save && @route_4.save && @route_5.save && @route_6.save && @route_7.save && @route_8.save
  		redirect_to journey_routes_path(@journey)
  	else
  		render :new
  	end
	end

	def show
		@journey = Journey.find(params[:id])
	end

	private

	def journey_params
		params.require(:journey).permit(:name, :user_id, :origin_string, :destination_string, :time_must_arrive_by_string)
	end

end
