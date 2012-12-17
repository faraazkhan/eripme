class CreateCreditCardsCustomersAndDiscounts < ActiveRecord::Migration
  def up
    create_table "credit_cards", :force => true do |t|
      t.string   "crypted_number"
      t.string   "last_4"
      t.string   "first_name"
      t.string   "last_name"
      t.string   "phone"
      t.integer  "customer_id"
      t.integer  "month"
      t.integer  "year"
      t.integer  "address_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  create_table "customers", :force => true do |t|
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "customer_address"
    t.string   "customer_city"
    t.string   "customer_state"
    t.string   "customer_zip"
    t.string   "customer_phone"
    t.integer  "coverage_type",                            :default => 1
    t.string   "coverage_addon"
    t.string   "home_type",                 :limit => 20
    t.string   "pay_amount"
    t.integer  "num_payments",                             :default => 0
    t.integer  "disabled",                                 :default => 1
    t.integer  "coverage_end"
    t.datetime "coverage_ends_at"
    t.string   "subscription_id"
    t.integer  "validated",                                :default => 0
    t.string   "customer_comment",          :limit => 512
    t.string   "credit_card_number_hash",   :limit => 500
    t.string   "expirationDate"
    t.integer  "status_id",                                :default => 0, :null => false
    t.integer  "timestamp"
    t.string   "ip"
    t.string   "billing_first_name"
    t.string   "billing_last_name"
    t.string   "billing_address"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_zip"
    t.integer  "agent_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.integer  "discount_id"
    t.integer  "cancellation_reason_id"
    t.integer  "icontact_id"
    t.string   "from"
    t.string   "service_fee_text_override"
    t.float    "service_fee_amt_override"
    t.string   "wait_period_text_override"
    t.integer  "wait_period_days_override"
    t.integer  "num_payments_override"
    t.string   "payment_schedule_override"
    t.string   "notes_override"
    t.integer  "home_size_code"
    t.integer  "home_occupancy_code"
    t.string   "work_phone"
    t.string   "mobile_phone"
  end

  add_index "customers", ["agent_id"], :name => "customers_agent_id_idx"
  add_index "customers", ["customer_city"], :name => "customers_city_idx"
  add_index "customers", ["customer_state"], :name => "customers_state_idx"
  add_index "customers", ["customer_zip"], :name => "customers_zip_idx"
  add_index "customers", ["email"], :name => "customers_email_idx"
  add_index "customers", ["last_name"], :name => "customers_last_name_idx"
  add_index "customers", ["status_id"], :name => "customers_status_id_idx"

  create_table "discounts", :force => true do |t|
      t.boolean  "is_monthly"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.float    "value"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def down
    drop_table :discounts
    drop_table :customers
    drop_table :credit_cards
  end
end
