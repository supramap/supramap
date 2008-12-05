class CreateSfiles < ActiveRecord::Migration
  def self.up
    create_table :sfiles do |t|
      t.references :project
      t.column :filename, :string
      t.column :created_at, :timestamp
      t.column :filetype, :string
    end
  end

  def self.down
    drop_table :sfiles
  end
end
