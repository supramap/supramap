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

    path = "#{FILE_SERVER_ROOT}/#{@job.project.user.login}/#{@job.project_id}/#{@job.id}/"
    # deletes the job folder if it's there
    FileUtils.rm_r(path) if File.exist?(path)

    redirect_to(:controller => "project", :action => "show", :id => @job.project_id)  
  end
    
  def create
    @sfiles = Sfile.find_all_by_project_id(params[:job][:project_id])
    @jobs = Job.find_all_by_project_id(params[:job][:project_id])
    @project = Project.find(params[:job][:project_id])
    
    @job = Job.new(params[:job])
    if @job.save
      path = "#{FILE_SERVER_ROOT}/#{@project.user.login}/#{@project.id}/#{@job.id}"
      FileUtils.mkdir(path) rescue nil
      FileUtils.chmod_R 0777, path
      @sfiles.each do |sfile|
        if params[:files][sfile.id.to_s] == "1"
          @job.sfiles << sfile
        end
      end
      # there should be separate actions for different kinds of jobs
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
    else
      flash[:notice] = "Job #{@job.name} could not be created."
    end
      redirect_to(:controller => "project", :action => "show", :id => @project.id)
  end

end
