class CreateAccounts < ActiveRecord::Migration
  def up
    create_table "accounts", :force => true do |t|
      t.string   "email",                                       :null => false
      t.string   "password_hash",                               :null => false
      t.string   "role",          :limit => 20,                 :null => false
      t.integer  "parent_id",                                   :null => false
      t.string   "parent_type",   :limit => 20,                 :null => false
      t.integer  "timezone",                    :default => -5, :null => false
      t.datetime "created_at",                                  :null => false
      t.datetime "updated_at",                                  :null => false
      t.string   "last_login_ip"
      t.datetime "last_login_at"
    end

    add_index "accounts", ["email"], :name => "accounts_email_idx"
    add_index "accounts", ["parent_id"], :name => "accounts_par_id_idx"

  end

  def down
    drop_table :accounts
  end
end
