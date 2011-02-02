class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.references :project
      t.column :created_at, :timestamp
      t.column :completed_at, :timestamp
      t.column :name, :string
      t.column :status, :string
      t.column :job_type, :string
      t.column :job_code, :integer
    end
  end

  def self.down
    drop_table :jobs
  end
end
