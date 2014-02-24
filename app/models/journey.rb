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

		address = origin.get_origin_address
		self.origin_address = address

		coordinates = origin.get_origin_coordinates
		self.origin_coordinates = coordinates

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if address && coordinates
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

		address = destination.get_destination_address
		self.destination_address = address

		coordinates = destination.get_destination_coordinates
		self.destination_coordinates = coordinates

		# save user input only if user input was parsed correctly, else triggers validator and reloads form
		if address && coordinates
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
		token = Token.new
		inrix_route = InrixRoute.new(token, self.origin_coordinates, self.destination_coordinates, self.time_must_arrive_by, self.id)

		directions = inrix_route.directions # an array
		travel_times = inrix_route.travel_times # an array
		departure_times = inrix_route.departure_times # an array
		arrival_times = inrix_route.arrival_times # an array

		# save the routes to the database
		departure_times.zip(arrival_times, travel_times) do |departure_time, arrival_time, travel_time|
			route = self.routes.new(journey_id: self.id, departure_time: departure_time, arrival_time: arrival_time, travel_time: travel_time, directions: directions)
			route.save
		end

		# @inrix_routes = inrix_route.get_all_routes

		# binding.pry

		# @inrix_routes.each do |route|
		# 	option = self.routes.new(journey_id: self.id, departure_time: route["departure time"], arrival_time: route["arrival time"], travel_time: route["travel_time"], directions: directions)
		# 	option.save
		# end

	end

end

