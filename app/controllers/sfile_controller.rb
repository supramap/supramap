class SfileController < ApplicationController
  
  def add
    @project = Project.find(params[:id])
  end
  
  def create
    @sfile = Sfile.new(params[:sfile])
    
    if @sfile.save
      flash[:notice] = "File #{@sfile.filename} successfully uploaded."
    else
      flash[:notice] = "An error occurred uploading the file."
    end
        
    redirect_to(:controller => "project", :action => "show", :id => @sfile.project_id)
  end

  def delete
    @sfile = Sfile.find(params[:id])
    @sfile.destroy
    @project = Project.find(@sfile.project_id)
    path = "#{FILE_SERVER_ROOT}/#{@project.user.login}/#{@project.id}/#{@sfile.filename}"
      
    FileUtils.rm_r(path) unless !File.exist?(path)
    redirect_to(:controller => "project", :action => "show", :id => @sfile.project_id)
  end

end
