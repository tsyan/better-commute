require 'chronic'

class Journey < ActiveRecord::Base
	belongs_to :user
	has_many :routes

	# defines origin_string in terms of something that exists in the database
	def origin_string
		origin_address
	end

	# defines origin_coordinates and origin_address from user input and stores it in the database
	def origin_string=(user_input)
		search_url = "http://maps.googleapis.com/maps/api/geocode/xml?address=#{user_input}&bounds=42.215297,-71.350708|42.548022,-70.883789&sensor=false"

		lat = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["geometry"]["location"]["lat"]
		lon = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["geometry"]["location"]["lng"]

		number = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][0]["short_name"]
		street = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][1]["short_name"]
		city = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][3]["short_name"]
		state = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][5]["short_name"]
		zip = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][7]["short_name"]

		self.origin_coordinates = lat + "," + lon

		address = number + " " + street + ", " + city + " " + state + " " + zip
		self.origin_address = address.to_s
	end




	# if i ever need to call @journey.time_must_arrive_by_string, this is what it will return, using the data as it is stored in the database
	def time_must_arrive_by_string
		time_must_arrive_by.to_s
	end

	# this method sets the user input from :time_must_arrive_by_string to :time_must_arrive_by and stores it in the database
	def time_must_arrive_by_string=(user_input)
		self.time_must_arrive_by = Chronic.parse(user_input.to_s, now: Time.now)
	end



end


# user_input = "something"
# search_url = "http://maps.googleapis.com/maps/api/geocode/xml?address=#{user_input}&bounds=38.959409,-76.245117|-68.906250&sensor=false"

# lat = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["geometry"]["location"]["lat"]
# lon = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["geometry"]["location"]["lng"]

# number = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][0]["short_name"]
# street = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][1]["short_name"]
# city = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][3]["short_name"]
# state = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][5]["short_name"]
# zip = HTTParty.get(URI.encode(search_url))["GeocodeResponse"]["result"]["address_component"][7]["short_name"]

# point = lat + "," + long
# address = number + " " + street + ", " + city + " " + state + " " + zip
