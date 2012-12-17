class CreateCoveragesPackages < ActiveRecord::Migration
  def up
     create_table "coverages_packages", :id => false, :force => true do |t|
      t.integer "coverage_id"
      t.integer "package_id"
    end

  end

  def down
    drop_table :coverages_packages
  end
end
