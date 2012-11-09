class IshowController < ApplicationController
  layout "main"
  skip_before_filter :authorize

#* _lt => less than
#* _gt => greater than
#* _lte => less than or equal to
#* _gte => greater than or equal to
#* _ne => not equal to
#* _not => not equal to

  def index
    respond_to do |format|
        format.html { redirect_to site_url }
    end
  end

  def show

    @path = "#{Rails.root}/public"
    tabimages = 14
    @ids = []
    @image = Image.find(params[:id])
    imagerange = Image.all(:conditions  => ['gallery_id = ? AND id < ? AND id > ?', @image.gallery_id,@image.id+tabimages ,@image.id-tabimages])
    imagerange.each do |img|
      @ids << img.id.to_i
    end
    arr_id = @ids.index(params[:id].to_i)

    @next_img_id = @ids[arr_id+1] if @ids[arr_id+1]
    @prev_img_id = @ids[arr_id-1] if @ids[arr_id-1] and arr_id != 0

    @startid = arr_id - tabimages/2
    @endid = arr_id + tabimages/2
    if @ids.length < tabimages 
      @startid = 0
      @endid = @ids.length - 1
    elsif arr_id < (tabimages - 1)
      @startid = 0
      @endid = (tabimages - 1)
    elsif arr_id > (@ids.length - tabimages)
      @startid = @ids.length - tabimages
      @endid = @ids.length - 1
    end

    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @images }
    end
  end

end
