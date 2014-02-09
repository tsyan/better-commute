class Route < ActiveRecord::Base
	belongs_to :journey


	def readable_travel_time
		# binding.pry
		num_of_hours = if travel_time / 60 > 1
			(travel_time / 60).to_s + " hrs "
		elsif travel_time / 60 == 1
			(travel_time / 60).to_s + " hr "
		elsif travel_time / 60 == 0
			""
		end

		num_of_minutes = if travel_time % 60 > 0
			(travel_time % 60).to_s + " min"
		elsif travel_time % 60 == 0
			""
		end

		num_of_hours + num_of_minutes

	end


end
