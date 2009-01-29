class Project < ActiveRecord::Base
  belongs_to :user
  has_many :sfiles
  has_many :jobs
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
  def get_sfiles_with_exts(exts = [])
    @sfiles = [] if @sfiles.nil?
    @sfiles.select { |f| exts.includes?(f.filetype) }
  end

end

