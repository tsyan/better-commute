class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		# @user = User.new("Test") # later this should be an if-else-end statement, if user is logged in then set @user as User.find(id)
		@journey = Journey.new(journey_params)

		unless @journey.save
			flash[:error] = @journey.errors.full_messages.join(", ")
			redirect_to new_journey_path
			return
		end

		token = Token.new

		inrix_route = InrixRoute.new(token, @journey.origin_coordinates, @journey.destination_coordinates, @journey.time_must_arrive_by, @journey.id)

		route_id = inrix_route.id
		directions = inrix_route.directions # directions is an array
		first_departure_time = inrix_route.first_departure_time

		travel_times = inrix_route.travel_times # travel_times is an array
		departure_times = inrix_route.departure_times # an array
		arrival_times = inrix_route.arrival_times # an array

		# save the routes to the database
		departure_times.zip(arrival_times, travel_times) do |d, a, t|
			route = @journey.routes.new(journey_id: @journey.id, departure_time: d, arrival_time: a, travel_time: t, directions: directions)
			if route.save
				hi = "yup!"
			else
				flash[:error] = route.errors.full_messages.join(", ")
				redirect_to new_journey_path
				return
			end
		end

		redirect_to journey_routes_path(@journey)

	end

	def show
		@journey = Journey.find(params[:id])
	end

	private

	def journey_params
		params.require(:journey).permit(:origin_string, :destination_string, :time_must_arrive_by_string)
	end

end
