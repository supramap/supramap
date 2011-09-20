class JobController < ApplicationController

  def define
    @project = Project.find(params[:id])
    @sfiles = Sfile.find_all_by_project_id(@project.id)
  end
  
  def select_files
    if params['cancel']
      redirect_to(:controller => "project", :action => "show", :id => params[:job][:project_id])
    else
      @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    end
  end

  def delete
    @job = Job.find(params[:id])
    @job.destroy
    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
  end

  
  def create
    if params['cancel']
      redirect_to(:controller => "project", :action => "show", :id => params[:job][:project_id])
      return
    end
    
    @job = Job.new(params[:job])
    if @job.save
      if @job.start[0].to_i == 0
        flash[:notice] = "Job #{@job.name} successfully created and started."
        redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
        return
      else
        @job.destroy
        # don't need to show flash message if errors exist
        flash[:notice] = "Job #{@job.name} could not be started." if @job.errors.empty?
      end
    end
    @project = Project.find(@job.project_id)
    @sfiles = Sfile.find_all_by_project_id(@project.id)
    render(:action => "define")
  end

  def stop
    @job = Job.find(params[:id])
    @job.stop
    flash[:notice] = "Job #{@job.name} successfully stopped."
    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)
  end
end
