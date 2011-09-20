class SfileController < ApplicationController
  
  def add
    @project = Project.find(params[:id])
  end
  
  def create
    @sfile = Sfile.new(params[:sfile])  
    if @sfile.save
      flash[:notice] = "File #{@sfile.name} successfully uploaded."
      redirect_to(:controller => "project", :action => "show", :id => @sfile.project_id)
    else
      @project = Project.find(@sfile.project_id)
      render(:action => "add")
    end
  end

  def delete
    @sfile = Sfile.find(params[:id])
    @sfile.destroy
    @project = Project.find(@sfile.project_id)
    path = "#{FILE_SERVER_ROOT}/#{@project.user.login}/#{@project.id}/#{@sfile.name}"
      
    FileUtils.rm_r(path) unless !File.exist?(path)
    redirect_to(:controller => "project", :action => "show", :id => @sfile.project_id)
  end

end
