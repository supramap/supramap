class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :firstname, :string
      t.column :lastname, :string
      t.column :login, :string
      t.column :hashed_password, :string
      t.column :email, :string
      t.column :salt, :string
      t.column :admin, :boolean
      t.column :auth, :boolean
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
