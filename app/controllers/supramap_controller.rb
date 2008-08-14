require "soap/rpc/driver"
require 'soap/wsdlDriver'
require "rexml/document"
require "fastercsv"

class SupramapController < ApplicationController

  before_filter :authorize, :except => [:index, :home, :about, :tutorials, :theory, :publications, :contact_us]

  def projects
    @page_id = "supramap"
    @page_title = "Projects"
    @projects = Project.find_all_by_user_id(session[:user_id])
  end

  def create_project
    @page_id = "supramap"
    @page_title = "Projects"
    @projects = Project.find_all_by_user_id(session[:user_id])
    
    @project = Project.new(params[:project])

    if @project.save
      path = "#{RAILS_ROOT}/public/files/#{@project.user.login}"
      if File.exist?(path) == false
        FileUtils.mkdir(path)
      end
      if File.exist?("#{path}/#{@project.id}") == false
        FileUtils.mkdir("#{path}/#{@project.id}")
      end
      flash[:notice] = "Project #{@project.name} successfully created."
      redirect_to :action => "projects"
    else
       render :action => "projects"
    end
  end
  
  def delete_project
    @project = Project.find(params[:id])
    @project.destroy
    @project.sfiles.each do |file|
      deletefile(file.id)
    end
    @project.jobs.each do |job|
      deletejob(job.id)
    end
    # delete project files as well
    FileUtils.rm_r("#{RAILS_ROOT}/public/files/#{@project.user.login}/#{@project.id}")
    redirect_to :action => "projects"
  end

  def edit_project
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @page_title = "Edit #{@project.name}"
  end

  def update_project
    @page_id = "supramap"
    @page_title = "Show project"
    
    @project = Project.find(params[:id])
    
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)

    if @project.update_attributes(params[:name])
      flash[:notice] = "Project #{@project.name} successfully updated."
      redirect_to :action => "show_project", :id => @project.id
    else
      render :action => "show_project", :id => @project.id
    end
  end


  def show_project
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @page_title = "Show project #{@project.name}"
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)
    @page_title = @project.name
  end

  def add_file
    @page_id = "supramap"
    @paget_title = "Add file"
    @sfile = Sfile.new
    @project = Project.find(params[:id])
    #need to make new view for upload file form!
  end
  
  def get_readme
    send_file("files/README.txt", :filename => 'yo_readme.txt')
  end

  def show_file
    @sfile = Sfile.find params[:id]
  end

  def create_file
    @page_id = "supramap"
    @page_title = "Show project"
    
    @sfile = Sfile.new(params[:sfile])
    
    @sfiles = Sfile.find_all_by_project_id(@sfile.project.id)
    @jobs = Job.find_all_by_project_id(@sfile.project.id)
    @project = Project.find(@sfile.project.id)
    
    if @sfile.save
      flash[:notice] = "File #{@sfile.filename} successfully uploaded."
      redirect_to :action => "show_project", :id => @sfile.project_id
    else
      #flash[:notice] = "File didn't upload!"
      render :action => "show_project", :id => @sfile.project_id
    end
  end


  def delete_file
    @sfile = Sfile.find(params[:id])
    @project = Project.find(@sfile.project_id)
    @sfile.destroy
    path = "#{RAILS_ROOT}/public/files/#{@project.user.login}/#{@project.id}/#{@sfile.filename}"
    if File.exist?(path)
      FileUtils.rm_r(path)
    end
    redirect_to :action => "show_project", :id => @sfile.project_id
  end

  def deletefile(id)
    Sfile.find(id).destroy  
  end


  def delete_job
    @job = Job.find(params[:id])
    @job.destroy
    # delete directory as well
    path = "#{RAILS_ROOT}/public/files/#{@job.project.user.login}/#{@job.project_id}/#{@job.id}/"
    if File.exist?(path)
      FileUtils.rm_r(path)
    end
    redirect_to :action => "show_project", :id => @job.project_id      
  end

  def deletejob(id)
    Job.find(id).destroy
  end
  
  def job_type
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @page_title = "Define new job"
    @sfiles = Sfile.find_all_by_project_id(@project.id)
  end

  def add_job
    #@project = Project.find(params[:job][:project_id])
    @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    @page_id = "supramap"
    @page_title = "Define job #{params[:job][:name]}"
  end
  
  def create_job
    
    @page_id = "supramap"
    @page_title = "Show project"
  
    @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    @jobs = Job.find_all_by_project_id(params[:job][:project_id])
    @project = Project.find(params[:job][:project_id])
    
    @job = Job.new(params[:job])
    if @job.save
      path = "#{RAILS_ROOT}/public/files/#{@job.project.user.login}/#{@job.project_id}/#{@job.id}"
      FileUtils.mkdir(path) rescue nil
      FileUtils.chmod_R 0777, path
      @sfiles.each do |sfile|
        if params[:files][sfile.id.to_s] == "1"
          #@job.select_file(sfile)
          @job.sfiles << sfile
        end
      end
      if(@job.job_type == "fas")
        @job_status = start_fas_job(@job.id)[0]
      else
        @job_status = start_xml_job(@job.id[0])
      end
      if @job_status == "0"
        flash[:notice] = "Job #{@job.name} successfully created and started."
      else
        flash[:notice] = "Job #{@job.name} created but cannot start."
      end
      redirect_to :action => "show_project", :id => @job.project_id
    else
      render :action => "show_project", :id => @job.project_id
    end
  end

  
  def start_fas_job(job_id)
      driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
      driver.startPOYJob(job_id.to_i)
  end
    
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
    redirect_to :action => "projects"
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
