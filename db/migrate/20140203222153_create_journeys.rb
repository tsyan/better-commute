class CreateJourneys < ActiveRecord::Migration
  def change
    create_table :journeys do |t|
      t.text :name
      t.text :origin
      t.text :destination
      t.time :time_must_arrive_by
      t.references :user, index: true

      t.timestamps
    end
  end
end
