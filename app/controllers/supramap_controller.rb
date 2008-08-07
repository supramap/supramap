require "soap/rpc/driver"
require 'soap/wsdlDriver'
require "rexml/document"
require "fastercsv"

class SupramapController < ApplicationController

  before_filter :authorize, :except => [:index, :home, :make_a_supramap, :about, :tutorials, :theory, :publications, :contact_us]

  def projects
    @page_id = "supramap"
    @page_title = "Projects"
    @projects = Project.find_all_by_user_id(session[:user_id])
  end

  def create_project
    @project = Project.new(params[:project])
    @project.save
    flash[:notice] = "Project #{@project.name} successfully created."
    redirect_to :action => "projects"
  end

  def edit_project
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @page_title = "Edit #{@project.name}"
  end

  def update_project
    @project = Project.find(params[:id])
    @project.update_attributes(params[:name])
    flash[:notice] = "Project #{@project.name} successfully updated."
    redirect_to :action => "show_project", :id => @project.id
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
  
  # Not used, but can check whether the KML file is present
  def checkKML
    job = Job.find(params[:job_id])    
    @path = "#{RAILS_ROOT}/public/files/#{job.project.user.login}/#{job.project_id}/#{job.id}/kml_#{job.id}.kml"
    if File.exist?(@path)
      flash[:notice] = "KML for Job #{job.name} is done."
    else
      flash[:notice] = "Error: Couldn't find the KML for Job #{job.name}."
    end
    redirect_to :action => "show_project", :id => job.project_id
  end

  def show_file
    @sfile = Sfile.find params[:id]
  end

  def create_file
    @sfile = Sfile.new(params[:sfile])
    if @sfile.save
      flash[:notice] = "File #{@sfile.filename} successfully uploaded."
    else
      flash[:notice] = "File didn't upload!"
    end
    redirect_to :action => "show_project", :id => @sfile.project_id
  end


  def delete_file
    @sfile = Sfile.find(params[:id])
    @project = Project.find(@sfile.project_id)
    @sfile.destroy
    FileUtils.rm_r("#{RAILS_ROOT}/public/files/#{@project.user.login}/#{@project.id}/#{@sfile.filename}")
    redirect_to :action => "show_project", :id => @sfile.project_id
  end

  def deletefile(id)
    Sfile.find(id).destroy  
  end

  def delete_job
    @job = Job.find(params[:id])
    @job.destroy
    # delete directory as well
    FileUtils.rm_r("#{RAILS_ROOT}/public/files/#{@job.project.user.login}/#{@job.project_id}/#{@job.id}/")
    redirect_to :action => "show_project", :id => @job.project_id      
  end

  def deletejob(id)
    Job.find(id).destroy
  end

  def add_job
    #@project = Project.find(params[:job][:project_id])
    @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    @page_id = "supramap"
    @page_title = "Define job #{params[:job][:name]}"
  end
  
  def create_job
    job = Job.new(params[:job])
    job.save
    path = "#{RAILS_ROOT}/public/files/#{job.project.user.login}/#{job.project_id}/#{job.id}"
    FileUtils.mkdir(path) rescue nil
    FileUtils.chmod_R 0777, path
    @sfiles = Sfile.find(:all)
    @sfiles.each do |sfile|
      if params[:files][sfile.id.to_s] == "1"
        #@job.select_file(sfile)
        job.sfiles << sfile
      end
    end
    if start_job(job.id)[0] == "0"
      flash[:notice] = "Job #{job.name} successfully created and started."
    else
      flash[:notice] = "Job #{job.name} created but cannot start."
    end
    redirect_to :action => "show_project", :id => job.project_id
  end
  
  def restart_job
    job = Job.find(params[:id])
    if start_job(job.id)[0] == "0"
      flash[:notice] = "Job #{job.name} successfully created and started."
      job.update_attribute :status, "running"
    else
      flash[:notice] = "Job #{job.name} cannot start."
    end
    redirect_to :action => "show_project", :id => job.project_id
  end
  
  def start_job(job_id)
      driver = SOAP::WSDLDriverFactory.new(WSDL_URL).create_rpc_driver
      driver.startPOYJob(job_id.to_i)
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

    def assign_rank(job)
      @treenodes = Treenode.find_all_by_job_id(job.id)
      @treenodes.each do |node|
        unless Treenode.find_by_parent_id(node.id)
          node.rank = 0
          node.save
        end
      end
      id = "x"
      while (id != "root" and id != "HTU0") do
        #select parent_name,max(rank) from $trees_table WHERE rank>-1 and parent_name in (select strain_name from $trees_table WHERE rank is null) GROUP BY parent_name HAVING count(distinct strain_name)=2
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
