class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		@journey = Journey.new(journey_params)

		if !@journey.save
			flash.now[:error] = "Oops! Please fill in all fields and try again."
			render :new
			return
		end

		if !@journey.generate_routes
			flash.now[:error] = "Oops! Server trouble. Please try again."
			render :new
			return
		else
			redirect_to journey_routes_path(@journey)
		end
	end

	def show
		@journey = Journey.find(params[:id])
	end

	private

	def journey_params
		params.require(:journey).permit(:origin_string, :destination_string, :time_must_arrive_by_string, :time_can_leave_at_string)
	end

end
