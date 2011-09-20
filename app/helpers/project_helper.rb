module ProjectHelper

  def get_file_type(sfile)
    case sfile.filetype
    when "fasta" then get_fas_type(sfile.desc)
    else
      sfile.filetype
    end
  end

  def get_fas_type(desc)
    str = "fasta"
    (desc == "AA") ? "#{str}(AA)" :  "#{str}(Nu)"
  end
  
  def show_error_log(job)
    "<a href=\"/sm/files/#{job.project.user.login}/#{job.project_id}/#{job.id}/poy.log\">view log</a>" if job.status == "Abnormal Exit"
  end
end
