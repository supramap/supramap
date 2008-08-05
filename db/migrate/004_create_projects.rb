class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.references :user
      t.column :created_at, :timestamp
      t.column :name, :string
    end
  end

  def self.down
    drop_table :projects
  end
end
