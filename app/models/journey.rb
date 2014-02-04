require 'chronic'

class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes

	# if i ever need to call @journey.time_must_arrive_by_string, this is what it will return, using the data as it is stored in the database
	def time_must_arrive_by_string
		time_must_arrive_by.to_s
	end

	# this method sets the user input from :time_must_arrive_by_string to :time_must_arrive_by and stores it in the database
	def time_must_arrive_by_string=(user_input)
		self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.now)
	end

end
