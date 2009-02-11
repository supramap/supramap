require 'set'

module JobHelper

  # exts is a set because a category of files could have
  # a number of file extensions, e.g, fasta, fa, fn, fas
  def get_files_by_ext(files, exts = Set.new)
    files.find_all {|file| exts.include?(file.filetype)}
  end
  
  def show_files(sfiles, set_of_exts)
    files = get_files_by_ext(sfiles, set_of_exts)
    if files.size != 0
      render(:partial => "sfile", :collection => files)
    else
      "<tr><td>No files of this type uploaded</td></tr>"
    end
  end
  
  # locals should contain:
  #   title = title of table
  #   files = array of sfiles
  #   file_exts = the type of files the table should display, i.e., csv
  def show_table_for_files(locals={})
    render(:partial => "sfile_table", :locals => locals)
  end
end
