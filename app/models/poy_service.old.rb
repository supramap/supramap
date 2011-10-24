require 'rubygems'
require 'httparty'
require 'base64'
require 'net/http'
require 'uri'
require 'soap/wsdlDriver'
require 'cgi'

class Poy_service
  include HTTParty
  base_uri 'http://glenn-webservice.bmi.ohio-state.edu//PoyService.asmx'
  default_params

  def initialize()
  end

  def self.init
    get("/Init?passPhase=KEOSRAKECNKHSAPJCXNLYAXBLPEMAAXOFOLVFFTGBYKNGLFRSF")["int"]
  end

  def self.add_text_file(job_id,file_name,file_data)

    soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    soap.AddFile(:jobId => job_id,:fileData => file_data,:fileName => file_name.gsub(" ",""))
  end

  def self.add_file(job_id,file_name,file_data)
    encoded_file_data = Base64.encode64(file_data)
    soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    soap.AddFile(:jobId => job_id,:fileData => encoded_file_data,:fileName => file_name.gsub(" ",""))
  end
  
  def self.submit_poy(job_id,minutes)
   @hours = minutes.div(60);
   @minutes = minutes.modulo(60);
   get("/SubmitPoy?jobId=#{job_id}&numberOfNodes=20&wallTimeHours=#{@hours}&wallTimeMinutes=#{@minutes}")["string"]
  end

  def self.is_done_yet(job_id)
    results = get("/IsDoneYet?jobId=#{job_id}");
    return ((results["q1:boolean"] == 'true' )||(  results["boolean"] == 'true'))
  end

  def self.get_file(job_id,file_name)
    #get("/GetTextFile?jobId=#{job_id}&fileName=#{file_name.gsub(" ","")}")["string"]
    soap = SOAP::WSDLDriverFactory.new("http://glenn-webservice.bmi.ohio-state.edu/PoyService.asmx?wsdl").create_rpc_driver()
    return soap.GetTextFile(:jobId => job_id,:fileName => file_name).getTextFileResult
  end
  def self.delete(job_id)
    get("/PoyService.asmx/DeleteJob?jobId=#{job_id}")
  end
end
