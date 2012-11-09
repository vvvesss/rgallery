class CshowController < ApplicationController
  layout "main"
  skip_before_filter :authorize
  def index
    respond_to do |format|
        format.html { redirect_to site_url }
    end
  end
  def show 
    @columns = 3
    @galleries = Gallery.where(:category_id => params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @galleries }
    end
  end
end
