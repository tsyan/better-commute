class JourneysController < ApplicationController

	def new
		@journey = Journey.new
	end

	def create
		@user = User.new # later this should be an if-else-end statement, if user is logged in then set @user as user
		@journey = Journey.new(journey_params)

		if @journey.save
  		redirect_to journey_path
  	else
  		render :new
  	end

	end

	private

	def journey_params
		params.require(:journey).permit(:name, :user_id, :origin, :destination, :time_must_arrive_by)
	end

end
