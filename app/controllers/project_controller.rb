class ProjectController < ApplicationController
  
  def list
    @projects = Project.find_all_by_user_id(session[:user_id])
  end
  
  def create
    @page_id = "supramap"
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
    @project.destroy
    # deletes the files and job records in the mysql database
    @project.sfiles.each do |file|
      deletefile(file.id)
    end
    @project.jobs.each do |job|
      deletejob(job.id)
    end
    # delete project files on the server as well
    FileUtils.rm_r("#{FILE_SERVER_ROOT}/#{@project.user.login}/#{@project.id}")
    redirect_to :action => "list"
  end

  def edit
    @page_id = "supramap"
    @project = Project.find(params[:id])
  end

  def update
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)

    if @project.update_attributes(params[:name])
      flash[:notice] = "Project #{@project.name} successfully updated."
    end
    redirect_to :action => "list"
  end


  def show
    @page_id = "supramap"
    @project = Project.find(params[:id])
    @page_title = "Show project #{@project.name}"
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    @jobs = Job.find_all_by_project_id(@project.id)
  end
  
end


