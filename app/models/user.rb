class User < ActiveRecord::Base
	has_many :journeys, dependent: destroy
end
