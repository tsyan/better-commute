require 'chronic'

class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes

	def time_must_arrive_by_string
		time_must_arrive_by.to_s
	end

	def time_must_arrive_by_string=(user_input)
		self.time_must_arrive_by = Chronic.parse(user_input.to_s)
	end

	# # getter
	# # when the user asks for :full_name, this is what :full_name will return, using the data as it is stored in the database
  # def full_name
  #   [first_name, last_name].join(' ')
  # end

  # # setter
  # # this method sets the input from :full_name to :first_name and :last_name
  # def full_name=(name)
  #   split = name.split(' ', 2)
  #   self.first_name = split.first
  #   self.last_name = split.last
  # end

end
