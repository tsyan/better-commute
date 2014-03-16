class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.text :origin_address
      t.text :origin_coordinates
      t.text :destination_address
      t.text :destination_coordinates
      t.datetime :time_must_arrive_by
      t.datetime :time_can_leave_at
      t.text :directions, array: true, default: '{No directions available.}'

      t.timestamps
    end
  end
end
