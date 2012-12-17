class CreateCancellationReasons < ActiveRecord::Migration
  def up
    create_table "cancellation_reasons", :force => true do |t|
      t.string   "reason",     :default => ""
      t.datetime "created_at"
      t.datetime "updated_at"
    end

  end

  def down
    drop_table :cancellation_reasons
  end
end
