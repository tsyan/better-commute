class RoutesController < ApplicationController

	def index
		@journey = Journey.find(params[:journey_id])
		@routes = @journey.routes.order(departure_time: :asc)
	end

end
