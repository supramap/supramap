class Job < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :sfiles
  
  validates_presence_of :name, :status
  validates_uniqueness_of :name, :scope => :project_id

  attr_reader :path_to_job_dir    

  def initialize
    super
    @path_to_job_dir = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
  end

  # create job dir before job is created
  def after_create
    begin 
      path = path_to_job_dir
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
    path = path_to_job_dir
    FileUtils.rm_r(path) if File.exist?(path)

    if self.status == "Running"
      self.stop
    end
  end

  def path_to_job_dir

  end
  
  def start
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    stat = driver.startPOYJob(self.id)
    self.status = "Running" if stat == 0
    return stat
  end
  
  def stop
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    return driver.stopJob(self.id)
  end
end
