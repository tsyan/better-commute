# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140203222459) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "journeys", force: true do |t|
    t.text     "origin_address"
    t.text     "origin_coordinates"
    t.text     "destination_address"
    t.text     "destination_coordinates"
    t.datetime "time_must_arrive_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "journeys", ["user_id"], name: "index_journeys_on_user_id", using: :btree

  create_table "routes", force: true do |t|
    t.datetime "departure_time"
    t.datetime "arrival_time"
    t.integer  "travel_time"
    t.text     "directions",     default: ["0"], array: true
    t.integer  "journey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "routes", ["journey_id"], name: "index_routes_on_journey_id", using: :btree

end
