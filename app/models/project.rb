class Project < ActiveRecord::Base
  belongs_to :user
  has_many :sfiles
  has_many :jobs
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
end

