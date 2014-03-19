class Route < ActiveRecord::Base
	belongs_to :journey

	def self.create_all_routes(journey_id, all_routes)
		all_routes.each do |route|
			departure_time = Chronic.parse(route["departureTime"])
			travel_time = route["travelTimeMinutes"] rescue nil
			arrival_time = departure_time + 60*travel_time.to_i rescue nil
			self.create(journey_id: journey_id, departure_time: departure_time, arrival_time: arrival_time, travel_time: travel_time)
		end
	end

	def readable_travel_time

		# calculate number of hours with label
		num_of_hours = if self.travel_time / 60 > 1
			(self.travel_time / 60).to_s + " hrs "
		elsif self.travel_time / 60 == 1
			(self.travel_time / 60).to_s + " hr "
		elsif self.travel_time / 60 == 0
			""
		end

		# calculate number of minutes with label
		num_of_minutes = if self.travel_time % 60 > 0
			(self.travel_time % 60).to_s + " min"
		elsif self.travel_time % 60 == 0
			""
		end

		num_of_hours + num_of_minutes
	end
end
