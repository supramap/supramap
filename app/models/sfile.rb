require "ftools"

class Sfile < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :jobs
  validates_presence_of :filename, :filetype
  validates_uniqueness_of :filename, :scope => :project_id
  
  def uploaded_file=(file_field)
    return nil if file_field.nil? || file_field.size == 0 
    self.filename = file_field.original_filename.strip if respond_to?(:filename)
    self.filetype = filename
    path = "#{FILE_SERVER_ROOT}/#{project.user.login}/#{project_id}/#{@filename}"
    File.open(path, "wb") do |f|
      if !has_fasta_ext(self.filetype)
        f.write(file_field.read)
      else
        self.desc = get_fas_type_and_write(file_field.read, f)
      end
    end
    FileUtils.chmod_R 0777, path
  end
  
  def filename=(new_name)
    name = new_name.gsub(/^.*(\\|\/)/, '')
    name.gsub!(/[^\w\.\-]/, '_')
    write_attribute :filename, name
    @filename = name
  end
  
  def filetype=(file_name)
    type = file_name.split(".").last
    write_attribute :filetype, type
    @filetype = type
  end
  
  private

  def has_fasta_ext(ext)
    ext == "fas" ||  ext == "fa" ||  ext == "fast" ||  ext == "fasta" ||  ext == "fna"
  end
    
  # writes stream to file, but checks to see if the .fas file contains
  # amino acid or nucleotide sequences
  # note: assumes non-sequence lines start with '>', per fasta format
  def get_fas_type_and_write(stream, file)
    amino_chars_found = false
    stream.each_line do |line|
      file.write(line)
      # if a single amino acid char is found then don't check further
      if !amino_chars_found && (line.first != '>')
        amino_chars_found = amino_chars_in_str?(line)
      end
    end
    amino_chars_found ? "AA" : "Nu"
  end
  
  # [EFILOPQZ*] is the character set unique to amino acid sequences
  def amino_chars_in_str?(str)
    !(str =~ /[EFILOPQZ\*]/i).nil?
  end
end
