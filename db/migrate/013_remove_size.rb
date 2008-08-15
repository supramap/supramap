class RemoveSize < ActiveRecord::Migration
  def self.up
    remove_column :sfiles, :size
  end

  def self.down
  end
end
