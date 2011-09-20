require "soap/rpc/driver"
require 'soap/wsdlDriver'
require "rexml/document"
require "fastercsv"

class SupramapController < ApplicationController

  before_filter :authorize, :except => [:acknowledgements, :index, :home, :about, :tutorials, :theory, :publications, :contact_us]

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

  def csv_tre_to_kml
    @page_id = "csv_tre_to_kml"
    @page_title = "csv_tre_to_kml"
  end

  def create_kml

    uploaded_csv = params[:cvs]
    File.open('tmp/p.csv', 'w') do |file|
      file.write(uploaded_csv.read)
    end

    uploaded_tre = params[:tre]
    File.open('tmp/p.tre', 'w') do |file|
      file.write(uploaded_tre.read)
    end

    `script/csv.tre-to-kml_linux-x86 -tree tmp/p.tre -csv tmp/p.csv`
    #`mv result.kml public/result.kml`
     send_data IO.read('result.kml'), :filename => 'result.kml' , :type => "kml"

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
