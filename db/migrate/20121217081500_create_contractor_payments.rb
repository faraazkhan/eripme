class CreateContractorPayments < ActiveRecord::Migration
  def up
    
  create_table "contractor_payments", :force => true do |t|
    t.integer  "contractor_id"
    t.float    "amount"
    t.integer  "repair_id"
    t.datetime "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  end

  def down
    drop_table :contractor_payments
  end
end
