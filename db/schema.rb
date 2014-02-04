# encoding: UTF-8

ActiveRecord::Schema.define(version: 20140204004824) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "journeys", force: true do |t|
    t.text     "name"
    t.text     "origin"
    t.text     "destination"
    t.time     "time_must_arrive_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "day_of_travel"
  end

  add_index "journeys", ["user_id"], name: "index_journeys_on_user_id", using: :btree

  create_table "routes", force: true do |t|
    t.time     "departure_time"
    t.time     "arrival_time"
    t.integer  "travel_time"
    t.integer  "journey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["journey_id"], name: "index_routes_on_journey_id", using: :btree

  create_table "users", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
