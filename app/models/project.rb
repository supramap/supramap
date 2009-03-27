class Project < ActiveRecord::Base
  belongs_to :user
  has_many :sfiles, :dependent => :destroy
  has_many :jobs, :dependent => :destroy
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :user_id
  
  def get_sfiles_with_exts(exts = [])
    @sfiles = [] if @sfiles.nil?
    @sfiles.select { |f| exts.includes?(f.filetype) }
  end
  
  def before_destroy
    # delete project files on the server as well
    FileUtils.rm_r("#{FILE_SERVER_ROOT}/#{self.user.login}/#{self.id}")
  end

end

