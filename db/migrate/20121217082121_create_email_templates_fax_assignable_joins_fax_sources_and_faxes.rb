class CreateEmailTemplatesFaxAssignableJoinsFaxSourcesAndFaxes < ActiveRecord::Migration
  def up
    create_table "email_templates", :force => true do |t|
    t.string  "name",    :default => "",    :null => false
    t.text    "subject",                    :null => false
    t.text    "body",                       :null => false
    t.boolean "locked",  :default => false
  end

  create_table "fax_assignable_joins", :force => true do |t|
    t.integer  "fax_id"
    t.integer  "assignable_id"
    t.string   "assignable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fax_sources", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "number"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "password_hash"
  end

  create_table "faxes", :force => true do |t|
    t.string   "path"
    t.datetime "received_at"
    t.string   "sender_fax_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_id"
    t.integer  "message_id"
  end

  end

  def down
    drop_table :email_templates
    drop_table :fax_assignable_joins
    drop_table :faxes
  end
end
