class Treenode < ActiveRecord::Base
  
  belongs_to :job
  has_many :transformations
  validates_presence_of :strain_name
  validates_uniqueness_of :strain_name, :scope => :job_id
end
