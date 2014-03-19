class Journey < ActiveRecord::Base
	has_many :routes

	attr_accessor :origin_string, :destination_string, :time_must_arrive_by_string, :time_can_leave_at_string
	validate :presence_of_address_inputs, :uniqueness_and_parsing_of_time_input
	validates :time_must_arrive_by, :time_can_leave_at, time: true # app/validators/time_validator.rb
	validate :address_geocoding

	def origin_string=(user_input)
		origin = Location.new(user_input)
		self.origin_address = origin.address
		self.origin_coordinates = origin.coordinates
		@origin_string = user_input # save user input for form reload
	end

	def destination_string=(user_input)
		destination = Location.new(user_input)
		self.destination_address = destination.address
		self.destination_coordinates = destination.coordinates
		@destination_string = user_input # save user input for form reload
	end

	def time_must_arrive_by_string=(user_input)
		self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.zone.now)
		@time_must_arrive_by_string = user_input # save user input for form reload
	end

	def time_can_leave_at_string=(user_input)
		self.time_can_leave_at = Chronic.parse(user_input.to_s, now: Time.zone.now)
		@time_can_leave_at_string = user_input # save user_input for form reload
	end

	def generate_routes
		query = new_inrix_query
		Route.create_all_routes(self.id, query.all_routes)
		save_directions(query.directions)
		update_time_must_arrive_by(query.time_must_arrive_by)
	end

	private

	def presence_of_address_inputs
		if self.origin_string.blank? || self.destination_string.blank?
			errors.add(:origin_address, "You have to enter both addresses.")
		end
	end

	def address_geocoding # only triggered if both inputs exist
		if self.origin_address.blank? || self.destination_address.blank? # if both are blank, displays only one error message
			errors.add(:origin_address, "You have to enter two valid addresses.")
		end
	end

	def uniqueness_and_parsing_of_time_input # if both inputs are invalid, shows only one error to avoid duplication
		if self.time_can_leave_at_string.present? && self.time_must_arrive_by_string.present? # if user entered both
			errors.add(:time_can_leave_at_string, "You can only enter one time constraint.")
		elsif self.time_can_leave_at_string.blank? && self.time_must_arrive_by_string.blank? # if user entered neither
			errors.add(:time_can_leave_at_string, "You have to enter a valid time and/or date.")
		elsif self.time_can_leave_at_string.present? && self.time_can_leave_at.blank? # if user entered gibberish
			errors.add(:time_can_leave_at, "You have to enter a valid time and/or date.")
		elsif self.time_must_arrive_by_string.present? && self.time_must_arrive_by.blank? # if user entered gibberish
			errors.add(:time_must_arrive_by, "You have to enter a valid time and/or date.")
		end
	end

	def new_inrix_query
		InrixRoute.new(self.origin_coordinates, self.destination_coordinates, self.time_must_arrive_by, self.time_can_leave_at)
	end

	def save_directions(new_directions)
		self.update(directions: new_directions)
	end

	def update_time_must_arrive_by(new_time_must_arrive_by)
		self.update(time_must_arrive_by: new_time_must_arrive_by)
	end

end

