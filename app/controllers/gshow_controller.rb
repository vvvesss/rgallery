class GshowController < ApplicationController
  layout "main"
  skip_before_filter :authorize
  def index
    respond_to do |format|
        format.html { redirect_to site_url }
    end
  end
  def show
    @gallery = Gallery.find(params[:id])
    
    @sss = params[:perpage]
    @fff = params[:cols]
    @bbb = "prazno" if session[:cols].nil?
    session[:cols] = 3 if session[:cols].nil?
    session[:perpage] = 15 if ! session[:perpage]

    if params[:cols]
        session[:perpage] = (params[:cols].to_i)*5
        session[:cols] = params[:cols].to_i
    end
    if params[:perpage]
        session[:perpage] = params[:perpage].to_i
    end
    
    @images = Image.where(:gallery_id => params[:id ]).paginate page: params[:page], order: 'created_at asc', per_page: session[:perpage]
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @images }
    end

  end  
end