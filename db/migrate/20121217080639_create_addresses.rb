class CreateAddresses < ActiveRecord::Migration
  def up
    create_table "addresses", :force => true do |t|
      t.string   "address"
      t.string   "address2"
      t.string   "address3"
      t.string   "city",             :default => ""
      t.string   "state",            :default => ""
      t.string   "zip_code",         :default => ""
      t.string   "country",          :default => "United States of America"
      t.integer  "addressable_id"
      t.string   "addressable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "address_type",     :default => "Property"
      t.float    "lat"
      t.float    "lng"
      t.string   "verified_address"
      t.string   "geocoded_address"
    end

    add_index "addresses", ["address_type"], :name => "addresses_address_type_idx"
    add_index "addresses", ["addressable_id"], :name => "addresses_addressable_id_idx"
    add_index "addresses", ["addressable_type"], :name => "addresses_addressable_type_idx"
    add_index "addresses", ["zip_code"], :name => "addresses_zip_code_idx"

  end

  def down
    drop_table :addresses
  end
end
