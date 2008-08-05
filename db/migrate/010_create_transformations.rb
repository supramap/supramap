class CreateTransformations < ActiveRecord::Migration
  def self.up
    create_table :transformations do |t|
      t.references :treenode
      t.column :definite, :bool
      t.column :ancestral_state, :string
      t.column :descendant_state, :string
      t.column :position, :integer
      t.column :type, :string
      t.column :cost, :string
      t.column :character, :string
    end
  end

  def self.down
    drop_table :transformations
  end
end
