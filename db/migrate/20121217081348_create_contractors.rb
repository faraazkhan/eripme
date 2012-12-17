class CreateContractors < ActiveRecord::Migration
  def up
     create_table "contractors", :force => true do |t|
        t.string   "first_name",         :default => "",      :null => false
        t.string   "last_name",          :default => "",      :null => false
        t.string   "company",                                 :null => false
        t.string   "job_title",          :default => "",      :null => false
        t.string   "phone",              :default => "",      :null => false
        t.string   "mobile",             :default => "",      :null => false
        t.string   "fax",                :default => "",      :null => false
        t.string   "email",              :default => "",      :null => false
        t.string   "priority",           :default => "",      :null => false
        t.string   "notes",              :default => ""
        t.datetime "created_at"
        t.datetime "updated_at"
        t.string   "receive_invoice_as", :default => "email"
        t.integer  "rating",             :default => 0
        t.boolean  "flagged",            :default => false
        t.string   "url"
      end

  end

  def down
    drop_table :contractors
  end
end
