class CreateRoutes < ActiveRecord::Migration
  def change
    create_table :routes do |t|
      t.datetime :departure_time
      t.datetime :arrival_time
      t.integer :travel_time
      t.text :directions, array: true, default: '{0}'
      t.references :journey, index: true

      t.timestamps
    end
  end
end
