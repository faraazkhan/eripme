class CreateIContactRequestsNotesNotificationsPackagesAndProperties < ActiveRecord::Migration
  def up
    create_table "i_contact_requests", :force => true do |t|
    t.string   "path",                      :null => false
    t.string   "put",        :limit => 512
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notes", :force => true do |t|
    t.integer  "customer_id", :default => 0, :null => false
    t.text     "note_text",                  :null => false
    t.integer  "timestamp",   :default => 0, :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "repair_id"
    t.integer  "author_id"
    t.string   "agent_name"
  end

  add_index "notes", ["customer_id"], :name => "notes_cust_id_idx"

  create_table "notifications", :force => true do |t|
    t.string   "message"
    t.string   "notification_type"
    t.integer  "level",             :default => 0
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "subject_summary"
    t.integer  "actor_id"
    t.string   "actor_type"
    t.string   "actor_summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string "package_name"
    t.float  "single_price",   :default => 0.0
    t.float  "condo_price",    :default => 0.0
    t.float  "duplex_price",                    :null => false
    t.float  "triplex_price",                   :null => false
    t.float  "fourplex_price",                  :null => false
  end

  create_table "properties", :force => true do |t|
    t.integer  "customer_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "properties", ["city"], :name => "properties_city_idx"
  add_index "properties", ["customer_id"], :name => "properties_cust_id_idx"
  add_index "properties", ["state"], :name => "properties_state_idx"
  add_index "properties", ["zip"], :name => "properties_zip_idx"

  end

  def down
    drop_table :i_contact_requests
    drop_table :notes
    drop_table :notifications
    drop_table :packages
    drop_table :properties
  end
end
