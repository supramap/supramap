require "soap/rpc/driver"
require 'soap/wsdlDriver'
require "rexml/document"
require "fastercsv"

class SupramapController < ApplicationController

  before_filter :authorize, :except => [:index, :home, :about, :tutorials, :theory, :publications, :contact_us]


  def deletejob(id)
    Job.find(id).destroy
  end

  
#   def job_type
#     @page_id = "supramap"
#     @project = Project.find(params[:id])
#     @page_title = "Define new job"
#     @sfiles = Sfile.find_all_by_project_id(@project.id)
#  end



#   def add_job
#     #@project = Project.find(params[:job][:project_id])
#     #@sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
#     @page_id = "supramap"
#     @page_title = "Define job #{params[:job][:name]}"
#   end

  # this is implemented
  def start_fas_job(job_id)
      driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
      driver.startPOYJob(job_id.to_i)
  end
  
  # this has not yet been implemented in JBoss
  def start_xml_job(job_id)
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
    #driver.startPOYJob(job_id.to_i)
  end

  def stop_job
    job = Job.find(params[:id]) 
    driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver 
    if driver.stopPOYJob(job.id)[0] == "0"
      flash[:notice] = "Job #{job.name} successfully stopped."
      job.update_attribute :status, "Stopped"
    else
      flash[:notice] = "Job #{job.name} couldn't be stopped."
    end
    redirect_to :action => "show_project", :id => job.project_id
  end

  # Query interface parses xml and csv each time, AJAX would be nice here
  def view_table
    @page_id = "supramap"
    @page_title = "View"

    parse_xml
    parse_csv
    @treenodes = Treenode.find(:all)
    @query =  Query.new(params[:query])
    if request.post? and @query.save 
      # Display query for debugging
      flash.now[:notice] = "AncS #{@query.anc_state}  DescS #{@query.desc_state}  Position #{@query.position}   InDel #{@query.insdel}."
    end
  end

    def parse_xml
      job = Job.find(params[:job_id])
      xml = REXML::Document.new(File.open("#{RAILS_ROOT}/public/files/#{job.project.user.login}/#{job.project_id}/#{job.id}/poy_tree_xml_#{job.id}.xml"))
      #File.open("#{RAILS_ROOT}/public/files/#{job.project.user.login}/#{job.project_id}/#{job.id}/poy_tree_#{job.id}.xml")
      xml.elements.each("forest/tree/*") do |node| #xpath 'forest/tree/*' returns all nodes
        treenode = Treenode.new(:id => params[:id])
        treenode.strain_name = node.elements["id/text()"].to_s #xpath 'id/text()' returns the content of the id element of a node
        if parent = Treenode.find_by_strain_name(node.elements["ancestors/ancestor/@id"].to_s) #xpath 'ancestors/ancestor/@id' returns id attribute of ancestor element
          treenode.parent_id = parent.id
        end
        treenode.save
        if treenode.id #don't keep adding transformations again
          node.elements.each("transformations/*") do |t|
            transformation = Transformation.new(:treenode_id => treenode.id)
            transformation.character = t.attribute("Character").to_s
            transformation.position = t.attribute("Pos").to_s.to_i
            transformation.ancestral_state = t.attribute("AncS").to_s
            transformation.descendant_state = t.attribute("DescS").to_s
            transformation.type = t.attribute("type").to_s
            transformation.cost = t.attribute("Cost").to_s.to_f
            if t.attribute("Definite").to_s == "true"
              transformation.definite = 1
            else
              transformation.definite = 0
            end
            transformation.save
          end
        end
      end
    end

    def parse_csv
      job = Job.find(params[:job_id])
      filename = ""
      Project.find_by_id(job.project_id).sfiles.each do |file|
        filename = file.filename if file.filename.include? ".csv"
      end
      csv = FasterCSV.read("#{RAILS_ROOT}/public/files/#{job.project.user.login}/#{job.project_id}/#{filename}")
      if !csv[0][0].include? "strain_name"
        flash[:notice] = "Invalid csv file. Expected 'strain_name', not '#{csv[0][0]}'"
      else
        csv.each do |line|
          if !line[0].include? "strain_name"
            treenode = Treenode.find_by_strain_name(line[0])
            if treenode
              treenode.latitude = line[1].to_s.to_f
              treenode.longitude = line[2].to_s.to_f
              treenode.isolation_date = line[3].to_time
              treenode.save
            end
          end
        end
      end
    end

  #actions for non-application pages

  def index
    redirect_to :action => "home"
  end

  def home
    @page_id = "home"
    @page_title = "Home"
  end

  def make_a_supramap
    redirect_to(:controller => "project", :action => "list")
  end

  def about
    @page_id = "about"
    @page_title = "About"
  end

  def tutorials
    @page_id = "tutorials"
    @page_title = "Tutorials"
  end

  def theory
    @page_id = "theory"
    @page_title = "Theory"
  end

  def publications
    @page_id = "publications"
    @page_title = "Publications"
  end

  def contact_us
    @page_id = "contact-us"
    @page_title = "Contact us"
  end

end
