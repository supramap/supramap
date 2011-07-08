class CovController < ApplicationController

  def index
            #render :controller=>'publication', :action => "pub3"
		render :template => 'publication/pub3'
  end


end
