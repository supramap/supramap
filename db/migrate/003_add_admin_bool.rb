class AddAdminBool < ActiveRecord::Migration
  def self.up
  end

  def self.down
    remove_column :products, :price
  end
end
