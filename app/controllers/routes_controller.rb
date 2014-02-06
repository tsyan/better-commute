class RoutesController < ApplicationController

	def index
		@journey = Journey.find(params[:journey_id])
		@route_1 = @journey.routes[0]
		@route_2 = @journey.routes[1]
		@route_3 = @journey.routes[2]
		@route_4 = @journey.routes[3]
		@route_5 = @journey.routes[4]
		@route_6 = @journey.routes[5]
		@route_7 = @journey.routes[6]
		@route_8 = @journey.routes[7]
	end

end
