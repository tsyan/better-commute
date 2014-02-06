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

		# save the route

		@route_1 = @journey.routes.create(departure_time: departure_time_1, arrival_time: arrival_time_1, travel_time: travel_time_1, journey_id: @journey.id)

		if @route_1.save
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
