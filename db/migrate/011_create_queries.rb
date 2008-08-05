class CreateQueries < ActiveRecord::Migration
  def self.up
    create_table :queries do |t|
      t.string :anc_state
      t.string :descs_state
      t.string :position
      t.string :insdel
      t.integer :job_id

      t.timestamps
    end
  end

  def self.down
    drop_table :queries
  end
end
