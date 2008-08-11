require "digest/sha1"

class User < ActiveRecord::Base
  has_many :projects
  validates_presence_of :firstname, :lastname, :login, :email 
  validates_uniqueness_of :login, :email

  validates_format_of:password,
  # modified from http://regexlib.com/REDetails.aspx?regexp_id=2204
  :with => /(?-i)(?=^.{8,}$)((?!.*\s)(?=.*[a-zA-Z]))((?=(.*\d){1,})|(?=(.*\W){1,}))^.*$/,
  :message => "(please enter a valid password with 6-20 characters and at least one non-letter)",
  :on => :create

  validates_format_of:login,
  # taken from http://regexlib.com/REDetails.aspx?regexp_id=145
  :with => /^[a-zA-Z0-9]+$/,
  :message => "(alphanumeric only)"

  validates_format_of:email,
  # taken from http://www.devx.com/enterprise/Article/31197/0/page/3
  :with => /\A[\w\._%-]+@[\w\.-]+\.[a-zA-Z]{2,4}\z/,
  :message => "(please enter a valid address)"

    
  validates_acceptance_of :eula
  
  attr_accessor :password_confirmation
  attr_reader :password

  validates_confirmation_of :password
  
  def validate
    errors.add_to_base("Missing password") if hashed_password.blank?
  end
  
  def hashed_pass
    self.hashed_password
  end
  
  def self.authenticate(login, password)
    user = self.find_by_login(login)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  def admin=(a)
    write_attribute(:admin, a)
  end
  
  def auth=(a)
    write_attribute(:auth, a)
  end
  
  def setA(ad, au)
    write_attribute(:admin, ad)
    write_attribute(:auth, au)
  end


  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  def after_destroy
    if User.count.zero?
      raise "Cannot delete last user"
    end
  end
  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "supramap" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  

end
