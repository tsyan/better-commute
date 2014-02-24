class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes
	validates_presence_of :origin_string, :destination_string, :time_must_arrive_by_string

	# defines origin_string so that it can pre-populate form fields when re-rendering form
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

	# defines destination_string so that it can pre-populate form fields when re-rendering form
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

	# defines time_must_arrive_by_string so that it can pre-populate form fields when re-rendering form
	def time_must_arrive_by_string
		@time_must_arrive_by_input
	end

	# defines time_must_arrive_by from user input and stores it in the database
	def time_must_arrive_by_string=(user_input)
		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.now)
			@time_must_arrive_by_input = user_input
		end
	end

	def generate_routes
		inrix_query = InrixRoute.new(self.origin_coordinates, self.destination_coordinates, self.time_must_arrive_by, self.id)

		directions = inrix_query.get_directions # an array
		results = inrix_query.get_all_routes # a hash

		results.each do |route|
			departure_time = Time.parse(route["departureTime"]).localtime
			travel_time = route["travelTimeMinutes"]
			arrival_time = departure_time + 60*travel_time.to_i
			self.routes.create(journey_id: self.id, departure_time: departure_time, arrival_time: arrival_time, travel_time: travel_time, directions: directions)
		end

	end

end

