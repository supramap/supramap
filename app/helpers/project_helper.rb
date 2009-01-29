module ProjectHelper

  def get_file_type(sfile)
    case sfile.filetype
    when "fas" then get_fas_type(sfile.desc)
    when "fasta" then get_fas_type(sfile.desc)
    when "fna" then get_fas_type(sfile.desc)
    when "fn" then get_fas_type(sfile.desc)
    else
      sfile.filetype
    end
  end

  def get_fas_type(desc)
    str = "fasta"
    (desc == "AA") ? "#{str}(AA)" :  "#{str}(Nu)"
  end
end
