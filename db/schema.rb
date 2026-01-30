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

ActiveRecord::Schema[7.1].define(version: 2026_01_30_022747) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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
    t.boolean "submitted", default: false
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

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "chat_id", null: false
    t.integer "user_id"
    t.text "content"
    t.integer "role", default: 0
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "race_drivers", force: :cascade do |t|
    t.integer "race_id", null: false
    t.integer "driver_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["driver_id"], name: "index_race_drivers_on_driver_id"
    t.index ["race_id"], name: "index_race_drivers_on_race_id"
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
    t.string "official_name"
    t.datetime "date_start"
    t.datetime "date_end"
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

  create_table "solid_cable_messages", force: :cascade do |t|
    t.text "channel"
    t.text "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bet_positions", "bets"
  add_foreign_key "bet_positions", "drivers"
  add_foreign_key "bets", "races"
  add_foreign_key "bets", "users"
  add_foreign_key "championship_results", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "users"
  add_foreign_key "race_drivers", "drivers"
  add_foreign_key "race_drivers", "races"
  add_foreign_key "results", "drivers"
  add_foreign_key "results", "races"
end
