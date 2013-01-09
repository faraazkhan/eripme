class RenameNameToFullNameOnCustomers < ActiveRecord::Migration
  def up
    rename_column :customers, :name, :full_name
  end

  def down
    rename_column :customers, :full_name, :name
  end
end
