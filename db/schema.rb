# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_19_195810) do
  create_table "bet_positions", force: :cascade do |t|
    t.integer "bet_id", null: false
    t.integer "driver_id", null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bet_id", "driver_id"], name: "index_bet_positions_on_bet_id_and_driver_id", unique: true
    t.index ["bet_id", "position"], name: "index_bet_positions_on_bet_id_and_position", unique: true
    t.index ["bet_id"], name: "index_bet_positions_on_bet_id"
    t.index ["driver_id"], name: "index_bet_positions_on_driver_id"
  end

  create_table "bets", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "race_id", null: false
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_id"], name: "index_bets_on_race_id"
    t.index ["user_id", "race_id"], name: "index_bets_on_user_id_and_race_id", unique: true
    t.index ["user_id"], name: "index_bets_on_user_id"
  end

  create_table "championship_results", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "year"
    t.integer "points"
    t.integer "rank"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_championship_results_on_user_id"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "api_id"
    t.string "headshot_url"
    t.index ["api_id"], name: "index_drivers_on_api_id"
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "start_time"
    t.integer "round_number"
    t.integer "year"
    t.string "location"
    t.string "api_session_id"
    t.string "race_type"
    t.string "status", default: "upcoming"
    t.integer "api_id"
    t.string "circuit_image_url"
    t.string "country_flag_url"
    t.index ["api_id"], name: "index_races_on_api_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "race_id", null: false
    t.integer "driver_id", null: false
    t.integer "position"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_results_on_driver_id"
    t.index ["race_id"], name: "index_results_on_race_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "admin", default: false, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bet_positions", "bets"
  add_foreign_key "bet_positions", "drivers"
  add_foreign_key "bets", "races"
  add_foreign_key "bets", "users"
  add_foreign_key "championship_results", "users"
  add_foreign_key "results", "drivers"
  add_foreign_key "results", "races"
end
