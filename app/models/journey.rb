require 'chronic'

class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes
	validates_presence_of :origin_string, :destination_string, :time_must_arrive_by_string

	# defines origin_string in terms of something that exists in the database
	def origin_string
		origin_address
	end

	# defines origin_coordinates and origin_address from user input and stores it in the database
	def origin_string=(user_input)
		return if user_input.blank?

		origin = Location.new(user_input)

		self.origin_address = origin.get_origin_address

		self.origin_coordinates = origin.get_origin_coordinates
	end

	# defines destination_string in terms of something that exists in the database
	def destination_string
		destination_address
	end

	# defines destination_coordinates and destination_address from user input and stores it in the database
	def destination_string=(user_input)
		return if user_input.blank?

		destination = Location.new(user_input)

		self.destination_address = destination.get_destination_address

		self.destination_coordinates = destination.get_destination_coordinates
	end

	# defines time_must_arrive_by_string in terms of something that exists in the database
	def time_must_arrive_by_string
		time_must_arrive_by.to_s
	end

	# defines time_must_arrive_by from user input and stores it in the database
	def time_must_arrive_by_string=(user_input)
		return if user_input.blank?

		self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.now)
	end

end

