class CreateContent < ActiveRecord::Migration
  def up
    create_table "content", :force => true do |t|
      t.string   "slug",       :null => false
      t.text     "html",       :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  add_index "content", ["slug"], :name => "content_slug_index"

  end

  def down
    drop_table :content
  end
end
