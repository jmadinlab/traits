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

ActiveRecord::Schema.define(version: 20140703014926) do

  create_table "citations", force: true do |t|
    t.integer  "trait_id"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "approval_status"
  end

  add_index "citations", ["resource_id"], name: "index_citations_on_resource_id"
  add_index "citations", ["trait_id"], name: "index_citations_on_trait_id"
  add_index "citations", ["user_id"], name: "index_citations_on_user_id"

  create_table "corals", force: true do |t|
    t.string   "coral_name"
    t.text     "coral_description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
  end

  add_index "corals", ["user_id"], name: "index_corals_on_user_id"

  create_table "imports", force: true do |t|
    t.string   "filename"
    t.string   "email"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "csv_file_file_name"
    t.string   "csv_file_content_type"
    t.integer  "csv_file_file_size"
    t.datetime "csv_file_updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "location_name"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.text     "location_description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id"

  create_table "measurements", force: true do |t|
    t.integer  "observation_id"
    t.integer  "user_id"
    t.integer  "orig_user_id"
    t.integer  "trait_id"
    t.integer  "standard_id"
    t.string   "value"
    t.string   "orig_value"
    t.string   "precision_type"
    t.string   "precision"
    t.string   "precision_upper"
    t.string   "replicates"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
    t.string   "value_type"
    t.integer  "methodology_id"
    t.string   "approval_status"
  end

  add_index "measurements", ["methodology_id"], name: "index_measurements_on_methodology_id"
  add_index "measurements", ["observation_id"], name: "index_measurements_on_observation_id"
  add_index "measurements", ["standard_id"], name: "index_measurements_on_standard_id"
  add_index "measurements", ["trait_id"], name: "index_measurements_on_trait_id"
  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id"

  create_table "methodologies", force: true do |t|
    t.string   "methodology_name"
    t.text     "method_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "methodologies_traits", id: false, force: true do |t|
    t.integer "trait_id"
    t.integer "methodology_id"
  end

  create_table "observations", force: true do |t|
    t.integer  "user_id"
    t.integer  "location_id"
    t.integer  "coral_id"
    t.integer  "resource_id"
    t.boolean  "private"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
  end

  add_index "observations", ["coral_id"], name: "index_observations_on_coral_id"
  add_index "observations", ["location_id"], name: "index_observations_on_location_id"
  add_index "observations", ["resource_id"], name: "index_observations_on_resource_id"
  add_index "observations", ["user_id"], name: "index_observations_on_user_id"

  create_table "resources", force: true do |t|
    t.string   "author"
    t.integer  "year"
    t.string   "title"
    t.string   "resource_type"
    t.string   "doi_isbn"
    t.string   "journal"
    t.string   "volume_pages"
    t.text     "resource_notes"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
  end

  add_index "resources", ["user_id"], name: "index_resources_on_user_id"

  create_table "standards", force: true do |t|
    t.string   "standard_name"
    t.string   "standard_unit"
    t.string   "standard_class"
    t.string   "standard_description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
  end

  add_index "standards", ["user_id"], name: "index_standards_on_user_id"

  create_table "traits", force: true do |t|
    t.string   "trait_name"
    t.integer  "standard_id"
    t.string   "value_range"
    t.string   "trait_class"
    t.text     "trait_description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approval_status"
    t.string   "release_status"
  end

  add_index "traits", ["standard_id"], name: "index_traits_on_standard_id"
  add_index "traits", ["user_id"], name: "index_traits_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin"
    t.boolean  "contributor"
    t.boolean  "editor"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

  create_table "versions", force: true do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.string   "ip"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
