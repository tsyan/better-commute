class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		# @user = User.new("Test") # later this should be an if-else-end statement, if user is logged in then set @user as User.find(id)
		@journey = Journey.new(journey_params)

		# doesn't fully work yet, rendering is wonky
		if !@journey.save
			flash[:error] = @journey.errors.full_messages.join(", ")
			render :new
			return
		end

		@journey.generate_routes

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
