# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.


class ApplicationController < ActionController::Base
  
  helper :all # include all helpers, all the time

  # don't show password in logs
  filter_parameter_logging "password"
    
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '24307b34c1af3c6cba4e2b51a6c99d1f'

  private

  def authorize
    user = User.find_by_id(session[:user_id])
    # If the user is not logged in
    if user.nil?
      flash[:notice] = "Please login to access this page."
      redirect_to :controller => "login", :action => "login"
    # If the user is not yet authorized
    # auth is a column in the table user and is by default false
    # an admin has to set auth to be true to allow a user to make a supramap
    elsif user.auth == false
      flash[:notice] = "Please wait for your account to be activated"
      redirect_to :controller => "supramap", :action => "home"
    end
  end

  def authorize_admin
    user = User.find_by_id(session[:user_id])
    # If the user is not logged in
    if user.nil?
      flash[:notice] = "Please login.  The page you requested can only be accessed by administrators."
      redirect_to :controller => "login", :action => "login"
    else
      unless user.admin?
        flash[:notice] = "The page you requested can only be accessed by administrators."
        redirect_to :controller => "supramap", :action => "projects"
      end
    end
  end
  
end
