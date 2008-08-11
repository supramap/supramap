require "ftools"

class Sfile < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :jobs
  validates_presence_of :filename, :filetype
  validates_uniqueness_of :filename, :scope => :project_id
  
  #attr_accessor :project_id
  
  def uploaded_file=(file_field)
    return nil if file_field.nil? || file_field.size == 0 
    self.filename = file_field.original_filename.strip if respond_to?(:filename)
    self.filetype = filename
    path = "#{RAILS_ROOT}/public/files/#{project.user.login}"
    File.open("#{path}/#{project_id}/#{@filename}", "wb") do |f|
      f.write(file_field.read)
    end
    path = "#{path}/#{project_id}/#{@filename}"
    FileUtils.chmod_R 0777, path
  end

  # taken care of by delete project in supramap_controller
  def after_destroy
    #path = "#{RAILS_ROOT}/public/files/#{project.user.login}/#{project_id}/#{filename}"
    #File.delete(path) if File.exist?(path)
  end
  
  def size=(s)
    write attribute :size, s
    @size = s
  end
  
  def filename=(new_name)
    name = new_name.gsub(/^.*(\\|\/)/, '')
    name.gsub!(/[^\w\.\-]/, '_')
    write_attribute :filename, name
    @filename = name
  end
  
  # extracts the extension of the file
  # not a good idea for security against bad files
  # use for project requirements
  
  def filetype=(new_type)
    type = new_type.split(".").last
    write_attribute :filetype, type
    @filetype = type
  end
  
  
end
