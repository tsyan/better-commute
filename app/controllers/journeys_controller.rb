class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		# @user = User.new("Test") # later this should be an if-else-end statement, if user is logged in then set @user as User.find(id)
		@journey = Journey.new(journey_params)

		# create the different routes here
		# first I will create one route

		@journey.save

		token = Token.new # later this should say if token.valid? continue, else get a new token

		# FindRoute

		find_route_url = "#{token.api_server}?Action=FindRoute&Token=#{token.value}&wp_1=#{@journey.origin_coordinates}&wp_2=#{@journey.destination_coordinates}&wp_1description=#{@journey.origin_address}&wp_2description=#{@journey.destination_address}&DepartureTime=2014-02-07T08:00:00-05:00&UseTraffic=true"
		find_route_response = HTTParty.get(URI.encode(find_route_url))["Inrix"]["Trip"]

		find_route_id = find_route_response["Route"]["id"]

		# GetRouteTravelTimes

		travel_times_url = "#{token.api_server}?Action=GetRouteTravelTimes&Token=#{token.value}&RouteID=#{find_route_id}&DepartureTime=2014-02-07T08:00:00-05:00&TravelTimeCount=6&TravelTimeInterval=5"
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

		# save the routes

		@route_1 = @journey.routes.create(departure_time: departure_time_1, arrival_time: arrival_time_1, travel_time: travel_time_1, journey_id: @journey.id)

		@route_2 = @journey.routes.create(departure_time: departure_time_2, arrival_time: arrival_time_2, travel_time: travel_time_2, journey_id: @journey.id)

		@route_3 = @journey.routes.create(departure_time: departure_time_3, arrival_time: arrival_time_3, travel_time: travel_time_3, journey_id: @journey.id)

		@route_4 = @journey.routes.create(departure_time: departure_time_4, arrival_time: arrival_time_4, travel_time: travel_time_4, journey_id: @journey.id)

		@route_5 = @journey.routes.create(departure_time: departure_time_5, arrival_time: arrival_time_5, travel_time: travel_time_5, journey_id: @journey.id)

		if @route_1.save && @route_2.save && @route_3.save && @route_4.save && @route_5.save
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
