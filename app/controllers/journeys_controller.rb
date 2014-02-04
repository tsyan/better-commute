class JourneysController < ApplicationController

	def show
		@journey = Journey.find(params[:id])
	end

	def new
		@journey = Journey.new
	end

	def create
		# @user = User.new("Test") # later this should be an if-else-end statement, if user is logged in then set @user as user
		@journey = Journey.new(journey_params)

		if @journey.save
  		redirect_to journey_path(@journey)
  	else
  		render :new
  	end

	end



	private

	def journey_params
		params.require(:journey).permit(:name, :user_id, :origin, :destination, :time_must_arrive_by, :day_of_travel)
	end

end
