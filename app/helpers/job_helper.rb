require 'set'

module JobHelper

  # exts is a set because a category of files could have
  # a number of file extensions, e.g, fasta, fa, fn, fas
  def get_files_by_ext(files, exts = Set.new)
    files.find_all {|file| exts.include?(file.filetype)}
  end
  
  def show_files(sfiles)
    render(:partial => "sfile", :collection => sfiles)
  end
  
  # locals should contain:
  #   title = title of table
  #   files = array of sfiles
  #   file_exts = the type of files the table should display, i.e., csv
  def show_table_for_files(locals={})
    files = get_files_by_ext(locals[:files], locals[:file_exts])
    unless files.empty?
      locals[:files] = files
      render(:partial => "sfile_table", :locals => locals)
    end
  end
end
