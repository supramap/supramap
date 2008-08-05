class Postoffice < ActionMailer::Base  
# located in models/postoffice.rb
# make note of the headers, content type, and time sent
# these help prevent your email from being flagged as spam
 
  def welcome(name, email)
    @recipients   = "supramap@gmail.com"
    @from         = "supramap@gmail.com"
    headers         "Reply-to" => "#{email}"
    @subject      = "Welcome to Supramap"
    @sent_on      = Time.now
    @content_type = "text/html"
 
    body[:name]  = name
    body[:email] = email       
  end
 
end