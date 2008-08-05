class CreateTreenodes < ActiveRecord::Migration
  def self.up
    create_table :treenodes do |t|
      t.references :job
      t.column :parent_id, :integer
      t.column :strain_name, :string
      t.column :rank, :integer
      t.column :latitude, :double
      t.column :longitude, :double
      t.column :isolation_date, :timestamp
    end
  end

  def self.down
    drop_table :treenodes
  end
end
