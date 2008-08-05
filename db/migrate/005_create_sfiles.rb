class CreateSfiles < ActiveRecord::Migration
  def self.up
    create_table :sfiles do |t|
      t.references :project
      t.column :name, :string
      t.column :created_at, :timestamp
      t.column :filetype, :string
      t.column :size, :integer
    end
  end

  def self.down
    drop_table :sfiles
  end
end
