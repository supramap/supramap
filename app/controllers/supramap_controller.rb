require "soap/rpc/driver"
require 'soap/wsdlDriver'
require "rexml/document"
require "fastercsv"

class SupramapController < ApplicationController

  before_filter :authorize, :except => [:index, :home, :about, :tutorials, :theory, :publications, :contact_us]

  def index
    redirect_to :action => "home"
  end

  def home
    @page_id = "home"
    @page_title = "Home"
  end

  def make_a_supramap
    redirect_to(:controller => "project", :action => "list")
  end

  def about
    @page_id = "about"
    @page_title = "About"
  end

  def tutorials
    @page_id = "tutorials"
    @page_title = "Tutorials"
  end

  def theory
    @page_id = "theory"
    @page_title = "Theory"
  end

  def publications
    @page_id = "publications"
    @page_title = "Publications"
  end

  def contact_us
    @page_id = "contact-us"
    @page_title = "Contact us"
  end

end
