class Job < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :sfiles
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  
  named_scope :status, lambda { |s|
    { :conditions => { :status => s } }
  }

  # create job dir before job is started
  def after_create
    begin 
      path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
      logger.error("Creating job dir: #{path}")
      FileUtils.mkdir(path)
      FileUtils.chmod_R(0777, path)
    rescue
      logger.error("An error occurred creating job dir for job: #{self.id}")
      return false
    end
  end

  # delete job dir after destroyed
  def after_destroy
    path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
    FileUtils.rm_r(path) if File.exist?(path)

    if self.status == "Running"
      self.stop
    end
  end
  
  def start
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    stat = driver.startPOYJob(self.id)
    self.status = "Running" if stat == 0
    return stat
  end
  
  def stop
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    # if an error occurred stopping job, then don't propogate to user
    if driver.stopJob(self.id)[0].to_i != 0
      self.status = "Stopped"
      self.save
    end
  end
end
