class CreateClaims < ActiveRecord::Migration
  def up
     create_table "claims", :force => true do |t|
        t.integer  "customer_id"
        t.string   "claim_timestamp"
        t.text     "claim_text"
        t.string   "standard_coverage"
        t.datetime "created_at",                       :null => false
        t.datetime "updated_at",                       :null => false
        t.integer  "address_id"
        t.string   "agent_name"
        t.integer  "status_code",       :default => 0
      end

    add_index "claims", ["claim_timestamp"], :name => "claims_tstamp_idx"
    add_index "claims", ["customer_id"], :name => "claims_cust_id_idx"

  end

  def down
    drop_table :claims
  end
end
