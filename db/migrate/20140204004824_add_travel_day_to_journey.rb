class AddTravelDayToJourney < ActiveRecord::Migration
  def change
    add_column :journeys, :day_of_travel, :text
  end
end
