class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.time :departure_time
      t.time :arrival_time
      t.integer :travel_time
      t.references :journey, index: true

      t.timestamps
    end
  end
end
