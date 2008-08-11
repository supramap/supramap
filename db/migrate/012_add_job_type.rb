class AddJobType < ActiveRecord::Migration
  def self.up
    add_column :jobs, :job_type, :string
  end

  def self.down
    remove_column :jobs, :job_type
  end
end
