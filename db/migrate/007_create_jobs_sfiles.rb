class CreateJobsSfiles < ActiveRecord::Migration
  def self.up
    create_table :jobs_sfiles, :id => false do |t|
      t.references :job
      t.references :sfile
    end
  end

  def self.down
    drop_table :jobs_sfiles
  end
end
