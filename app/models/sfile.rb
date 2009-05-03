require "ftools"

class Sfile < ActiveRecord::Base
  belongs_to :project
  has_and_belongs_to_many :jobs
  validates_presence_of :name, :ext, :filetype
  validates_uniqueness_of :name, :scope => :project_id
  
  def uploaded_file=(file_field)
    return nil if (file_field.nil? || file_field.size == 0)
    self.name = file_field.original_filename.strip if respond_to?(:name)
    self.ext = name
    path = "#{FILE_SERVER_ROOT}/#{project.user.login}/#{project_id}/#{@name}"
    File.open(path, "wb") do |f|
      if filetype != "fasta"
        f.write(file_field.read)
      else
        self.desc = get_fas_type_and_write(file_field.read, f)
      end
    end
    FileUtils.chmod_R(0777, path)
  end
  
  def name=(a_name)
    name = a_name.gsub(/^.*(\\|\/)/, '')
    name.gsub!(/[^\w\.\-]/, '_')
    write_attribute(:name, name)
    @name = name
  end
  
  def ext=(file_name)
    ext = file_name.split(".").last
    write_attribute(:ext, ext)
    @ext = ext
  end
  
  private
    
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
