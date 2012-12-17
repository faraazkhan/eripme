class CreateReferalsRenewalsRepairsSignatureHashesAndTransactions < ActiveRecord::Migration
  def up
     create_table "referals", :primary_key => "referal_id", :force => true do |t|
    t.string  "referal_text", :default => "", :null => false
    t.integer "timestamp",    :default => 0,  :null => false
  end

  create_table "renewals", :force => true do |t|
    t.date     "starts_at"
    t.date     "ends_at"
    t.float    "amount"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "years",       :default => 0
  end

  create_table "repairs", :force => true do |t|
    t.integer  "claim_id"
    t.integer  "contractor_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "authorization",  :default => 0,    :null => false
    t.float    "amount",         :default => 0.0,  :null => false
    t.integer  "status",         :default => 0
    t.float    "service_charge", :default => 60.0
  end

  create_table "signature_hashes", :force => true do |t|
    t.text     "signature_hash"
    t.integer  "account_id",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "response_code"
    t.string   "response_reason_text"
    t.string   "auth_code"
    t.float    "amount"
    t.integer  "transaction_id"
    t.integer  "customer_id"
    t.integer  "subscription_id"
    t.integer  "subscription_paynum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_agent_id"
  end

  add_index "transactions", ["customer_id"], :name => "transactions_cust_id_idx"
  add_index "transactions", ["original_agent_id"], :name => "transactions_orig_agent_id_idx"
  add_index "transactions", ["response_code"], :name => "response_code_index"
  add_index "transactions", ["subscription_id"], :name => "transactions_subs_id_idx"
  add_index "transactions", ["transaction_id"], :name => "transactions_trans_id_idx"

  end

  def down
    drop_table :referals
    drop_table :renewals
    drop_table :repairs
    drop_table :signature_hashes
    drop_table :transactions
  end
end
