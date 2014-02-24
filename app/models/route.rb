class Route < ActiveRecord::Base
	belongs_to :journey

	# converts travel time from integer minutes to hours and minutes
	# called by routes index view
	def readable_travel_time

		# calculate number of hours
		num_of_hours = if travel_time / 60 > 1
			(travel_time / 60).to_s + " hrs "
		elsif travel_time / 60 == 1
			(travel_time / 60).to_s + " hr "
		elsif travel_time / 60 == 0
			""
		end

		# calculate number of minutes
		num_of_minutes = if travel_time % 60 > 0
			(travel_time % 60).to_s + " min"
		elsif travel_time % 60 == 0
			""
		end

		num_of_hours + num_of_minutes

	end


end
