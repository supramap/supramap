class Job < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :sfiles
  
  validates_presence_of :name, :status
  validates_uniqueness_of :name, :scope => :project_id

  # create job dir before job is created
  def after_create
    begin 
      path = get_path
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
    path = get_path
    FileUtils.rm_r(path) if File.exist?(path)
  end

  def get_path
    "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
  end
  
  # this is implemented
  def start
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    stat = driver.startPOYJob(self.id)
    self.status = "Running" if stat == 0
    return stat
  end
  
end
