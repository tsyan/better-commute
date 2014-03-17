class Journey < ActiveRecord::Base
	has_many :routes
	validates_presence_of :origin_string, :destination_string
	validates_presence_of :time_must_arrive_by_string, unless: :time_can_leave_at?
	validates_presence_of :time_can_leave_at_string, unless: :time_must_arrive_by?

	validate :times

	def times
		if self.time_can_leave_at.present? && self.time_must_arrive_by.present?
			errors.add(:base, "nope")
		end
	end

	# defines origin_string so that it can pre-populate form fields when reloading form
	def origin_string
		@origin_input
	end

	# defines origin_coordinates and origin_address from user input and stores it in the database
	def origin_string=(user_input)
		origin = Location.new(user_input)
		self.origin_address = origin.address
		self.origin_coordinates = origin.coordinates

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if origin.address && origin.coordinates
			@origin_input = user_input
		end
	end

	# defines destination_string so that it can pre-populate form fields when reloading form
	def destination_string
		@destination_input
	end

	# defines destination_coordinates and destination_address from user input and stores it in the database
	def destination_string=(user_input)
		destination = Location.new(user_input)
		self.destination_address = destination.address
		self.destination_coordinates = destination.coordinates

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if destination.address && destination.coordinates
			@destination_input = user_input
		end
	end

	# defines time_must_arrive_by_string so that it can pre-populate form fields when reloading form
	def time_must_arrive_by_string
		@time_must_arrive_by_input
	end

	# defines time_must_arrive_by from user input and stores it in the database
	def time_must_arrive_by_string=(user_input)
		parsed_time = Chronic.parse(user_input.to_s, now: Time.now)

		begin
			# if arrival time is far in the past, leave as nil to trigger validator
			if parsed_time - Time.now < -86400
				parsed_time = nil
			# if arrival time is less than 24 hours ago, add one day (handles inputs like '4pm' when it's already 5pm)
			elsif parsed_time - Time.now < 0 && parsed_time - Time.now > -86400
				parsed_time = parsed_time + 86400
			end
		rescue
			parsed_time = nil
		end

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if self.time_must_arrive_by = parsed_time
			@time_must_arrive_by_input = user_input
		end
	end

	# defines time_can_leave_at_string so that it can pre-populate form fields when reloading form
	def time_can_leave_at_string
		@time_can_leave_at_input
	end

	# defines time_can_leave_at from user input and stores it in the database
	def time_can_leave_at_string=(user_input)
		parsed_time = Chronic.parse(user_input.to_s, now: Time.now)

		begin
			# if departure time is far in the past, leave as nil to trigger validator
			if parsed_time - Time.now < -86400
				parsed_time = nil
			# if departure time is less than 24 hours ago, add one day (handles inputs like '4pm' when it's already 5pm)
			elsif parsed_time - Time.now < 0 && parsed_time - Time.now > -86400
				parsed_time = parsed_time + 86400
			end
		rescue
			parsed_time = nil
		end

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if self.time_can_leave_at = parsed_time
			@time_can_leave_at_input = user_input
		end
	end

	def generate_routes
		inrix_query = InrixRoute.new(self.origin_coordinates, self.destination_coordinates, self.time_must_arrive_by, self.time_can_leave_at)

		return if !inrix_query.route_id || !inrix_query.directions || !inrix_query.first_departure_time

		inrix_query.get_all_routes.each do |route|
			departure_time = Chronic.parse(route["departureTime"])
			if route["averageSpeed"] == "0" # if route has closures
				travel_time = nil
				arrival_time = nil
			else
				travel_time = route["travelTimeMinutes"]
				arrival_time = departure_time + 60*travel_time.to_i
			end
			self.routes.create(journey_id: self.id, departure_time: departure_time, arrival_time: arrival_time, travel_time: travel_time)
		end

		self.update(directions: inrix_query.directions)
		self.update(time_must_arrive_by: inrix_query.time_must_arrive_by)

	end

end

