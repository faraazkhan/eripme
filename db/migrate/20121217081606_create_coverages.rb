class CreateCoverages < ActiveRecord::Migration
  def up
     create_table "coverages", :force => true do |t|
      t.string  "coverage_name"
      t.integer "optional",      :default => 0
      t.float   "price",         :default => 0.0
  end

  end

  def down
    drop_table :coverages
  end
end
