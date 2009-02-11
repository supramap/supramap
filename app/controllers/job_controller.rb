class JobController < ApplicationController
  
  def define
    @project = Project.find(params[:id])
    @page_title = "Define a new job"
  end
  
  def select_files
    unless params['cancel']
      @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    else
      redirect_to(:controller => "project", :action => "show", :id => params[:job][:project_id])
    end
  end
  
  def delete
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)  
  end

  def create
    @job = Job.new(params[:job])
    if @job.save && (@job.start == 0)
      flash[:notice] = "Job #{@job.name} successfully created and started."      
    else
      @job.destroy
      flash[:notice] = "Job #{@job.name} could not be created."
    end
    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
  end
end
