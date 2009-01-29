class Job < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :sfiles
  
  validates_presence_of :name, :status, :type
  validates_uniqueness_of :name, :scope => :project_id


  def self.select_file(file)
    sfiles << file
  end
end
