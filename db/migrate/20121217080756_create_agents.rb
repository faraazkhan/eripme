class CreateAgents < ActiveRecord::Migration
  def up
   create_table "agents", :force => true do |t|
      t.string  "name",                  :default => "", :null => false
      t.string  "email",                 :default => "", :null => false
      t.integer "admin",                 :default => 0,  :null => false
      t.integer "commission_percentage", :default => 8,  :null => false
    end
    add_index "agents", ["email"], :name => "agents_email_idx"
    add_index "agents", ["name"], :name => "agents_name_idx"
  end

  def down
    drop_table :agents
  end
end
