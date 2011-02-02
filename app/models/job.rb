require 'cgi'
#require 'poy_service'

class Job < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :sfiles
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :project_id
  
  named_scope :status, lambda { |s|
    { :conditions => { :status => s } }
  }


  def validate
    if sfiles.size < 2 || sfiles.select {|file| file.filetype == "geo"}.size != 1
      errors.add_to_base("You must select one csv file, and atleast one other file")
    end
  end
  
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
    Poy_service.delete(self.status)

    path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"
    FileUtils.rm_r(path) if File.exist?(path)

    if self.status == "Running"
      self.stop
    end
  end
  
  def start
    self.status = "Abnormal Exit"
    self.save
    project_path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/"
    job_path = project_path+"#{self.id}/"


    #sfiles.select {|file| file.filetype != "geo"}.each{ |f| puts f.name }
    read_poy_script_segment =''
    sfiles.each{ |f|
      case f.filetype
      when "geo"
          read_poy_script_segment<<""
      when "AA" 
        read_poy_script_segment<<"read(aminoacids: (\"#{f.name}\"))\n"
      when "pre"
        read_poy_script_segment<<"read(prealigned: (\"#{f.name}\", tcm:(1,1)))\n"
      when "fasta"
        read_poy_script_segment<<"read(\"#{f.name}\")\n"
      when "cat"
        read_poy_script_segment<<"read(\"#{f.name}\")\n"
      when "tree"
        read_poy_script_segment<<"read(\"#{f.name}\")\n"
      end
      }


    poy_script="#{read_poy_script_segment}
set(log: \"poy.log\")

transform(tcm:(1,1))
search(max_time:0:0:5, memory:gb:2)
select(best:1)
transform (static_approx)
report(\"#{name}_results.kml\", kml:(supramap, \"#{sfiles.select {|file| file.filetype == "geo"}[0].name}\"))

report(asciitrees)
report(\"#{name}_results.tre\",trees)
report(\"#{name}_results.stats\",treestats)
exit()"

    File.open(job_path+"script.psh", 'w') {|f|
      f.write(poy_script)
    }

     poy_job_id = Poy_service.init()
     self.job_code =  poy_job_id
    Poy_service.add_text_file(poy_job_id,"script.poy", poy_script)
    sfiles.each { |i|
      Poy_service.add_text_file(poy_job_id, i.name, File.open("#{project_path}#{i.name}", "r").read)
    }

    Poy_service.submit_poy(poy_job_id,60)
 self.status = "Running"
 self.save
 return 0;
    #### old logic here ######
#    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
#
#    begin
#      stat = driver.startPOYJob(self.id)
#    rescue SOAP::FaultError => error
#      logger.error(error)
#      stat = -1
#      errors.add_to_base(error)
#    end
#    self.status = "Running" if stat == 0
#    return stat
  end

  def is_done
    if(Poy_service.is_done_yet(self.job_code.to_s))
      path = "#{FILE_SERVER_ROOT}/#{self.project.user.login}/#{self.project_id}/#{self.id}/"

      file_string = Poy_service.get_file(self.job_code, "#{name}_results.kml")
      #puts file_string.public_methods

      File.open("#{path}#{name}_results.kml", 'w') {|f| f.write(file_string) }

      file_string = Poy_service.get_file(self.job_code, "#{name}_results.tre")
      File.open("#{path}#{name}_results.tre", 'w') {|f| f.write(file_string) }

      file_string = Poy_service.get_file(self.job_code, "#{name}_results.stats")
      File.open("#{path}#{name}_results.stats", 'w') {|f| f.write(file_string) }

      self.status = "Completed"
      self.save
     
    end
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
