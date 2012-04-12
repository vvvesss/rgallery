class SiteController < ApplicationController
  layout "main"
  skip_before_filter :authorize
  def index
    @gallery_thumbs = Image.where(:gthumb => true)
  end
end
