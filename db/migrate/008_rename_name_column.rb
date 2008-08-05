class RenameNameColumn < ActiveRecord::Migration
  def self.up
    rename_column :sfiles, :name, :filename
  end

  def self.down
    rename_column :sfiles, :filename, :name
  end
end
