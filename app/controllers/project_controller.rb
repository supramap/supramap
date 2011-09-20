class ProjectController < ApplicationController
  
  def list
    @projects = Project.find_all_by_user_id(session[:user_id])
  end
  
  def create
    @project = Project.new(params[:project])

    if @project.save
      path = "#{FILE_SERVER_ROOT}/#{@project.user.login}"
      # if the folders have not been created on the server, create them
      if File.exist?(path) == false
        FileUtils.mkdir(path)
      end
      if File.exist?("#{path}/#{@project.id}") == false
        FileUtils.mkdir("#{path}/#{@project.id}")
      end
      flash[:notice] = "Project #{@project.name} successfully created."
      redirect_to :action => "list"
    else
      # render allows for the errors to be displayed
       render :action => "list"
    end
  end
  
  def delete
    @project = Project.find(params[:id])
    name = @project.name

    if @project.jobs.status("Running").empty?
      @project.destroy
      flash[:notice] = "Project #{name} was successfully deleted."            
    else
      flash[:notice] = "All project jobs must be stopped before #{name} can be deleted."
    end
    redirect_to :action => "list"
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)

    if @project.update_attributes(params[:name])
      flash[:notice] = "Project #{@project.name} successfully updated."
    end
    redirect_to :action => "list"
  end


  def show
    @project = Project.find(params[:id])
    @page_title = "Show project #{@project.name}"
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)


    @jobs.select { |j| j.status == "Running"  }.each{ |j|j.is_done }
  end
  
end


