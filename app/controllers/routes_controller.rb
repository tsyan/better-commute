class RoutesController < ApplicationController

	def index
		@journey = Journey.find(params[:journey_id])
		@route_1 = @journey.routes[0]
	end

end
