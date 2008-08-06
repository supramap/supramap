class LoginController < ApplicationController

  layout "supramap"
  before_filter :authorize, :except => [:login, :logout, :register]
  before_filter :authorize_admin, :except => [:login, :logout, :register]
  
  # controllers/registration_controller.rb
  # assume the Registration controller already existed
  # assume @user.name and @user.email have been declared
  
  def send_welcome_email
    # triggered via:
    # http://localhost:3000/registration/send_welcome_email
 
    # note the deliver_ prefix, this is IMPORTANT
 
    if request.post?
      user = User.find(params[:id])
      Postoffice.deliver_welcome(user.firstname, user.email)
 
      # optional, but I like to keep people informed
      flash[:notice] = "You've successfuly registered. Please check your email for a confirmation!"
    end
    # render the default action
    redirect_to :action => 'list_users'  
  end


  def show_add_user
    redirect_to :action => "add_user"
  end

  def add_user
    @page_id = "supramap"
    @page_title = "Add User"

    @user = User.new(params[:user])
    if request.post? and @user.save 
      flash.now[:notice] = "User #{@user.login} added."
      @user = User.new
    end
  end

  def register
    @page_id = "supramap"
    @page_title = "Register"

    @user = User.new(params[:user])
    @user.setA(true, true)
    if request.post? and @user.save
      flash[:notice] = "User #{@user.login} created."
      @user = User.new
      redirect_to:action=>"login" 
    end
  end

  def login
    @page_id = "supramap"
    @page_title = "Login to SupraMap"

    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:login], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:controller => "supramap", :action => "projects"})
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "You have successfully logged out."
    redirect_to :action => "login"
  end

  def index
    redirect_to :action => "admin"
  end

  def admin
    @page_id = "supramap"
    @page_title = "User Administration"
  end

  def delete_user
    @page_id = "supramap"
    @page_title = "Delete User"
    
    if request.post?
      user = User.find(params[:id])
      user.destroy
    end
    redirect_to  :action => "list_users"
  end
  

  def changeAuth
    @page_id = "supramap"
    @page_title = "Change Authorization"
      if request.post?
        user = User.find(params[:id])
        user.auth = !(user.auth)
        user.save!
      end
      redirect_to :action => "list_users"
    end
  
  def changeAdmin
    @page_id = "supramap"
    @page_title = "Change Admin"

    if request.post?
      user = User.find(params[:id])
      user.admin = !(user.admin)
      user.save!
    end
    
    redirect_to :action => "list_users"
  end
    

  def list_users
    @page_id = "supramap"
    @page_title = "List Users"

    @all_users = User.find(:all)
  end
  
end
