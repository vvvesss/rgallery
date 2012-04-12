class ImagesController < ApplicationController
  # GET /images
  # GET /images.json
  def index
#    Image.delete_all
#    Gallery.delete_all
    @images = Image.all


    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @images }
    end
  end

  # GET /images/1
  # GET /images/1.json
  def show
    @image = Image.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/new
  # GET /images/new.json
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @image }
    end
  end

  # GET /images/1/edit
  def edit
    @image = Image.find(params[:id])
  end

  # POST /images
  # POST /images.json
  def create
  
    if params[:imgs]
      params[:imgs].each do |image|
         img = Image.find(image)
         /(.*)\.(jpg|png)/i.match(img.fname)
         iname = $1
         iformat = $2
         @path = "#{Rails.root}" #default upload path
         Dir.chdir(@path)                                   
         File.unlink("#{@path}/#{img.path}/originals/#{img.fname}")
         File.unlink("#{@path}/#{img.path}/image_thumb/#{iname}.#{iformat}")
         File.unlink("#{@path}/#{img.path}/75x75/#{iname}.#{iformat}")
         if File.exists?("#{@path}/#{img.path}/galery_thumb/#{iname}.png")
           File.unlink("#{@path}/images/galery_thumb/#{iname}.png")
         end
         img.destroy
      end
      respond_to do |format|
        format.html { redirect_to images_url, notice: 'Images deleted' }
        format.json { head :no_content }
      end      
    else  
      @image = Image.new(params[:image])

      respond_to do |format|
        if @image.save
          format.html { redirect_to @image, notice: 'Image was successfully created.' }
          format.json { render json: @image, status: :created, location: @image }
        else
          format.html { render action: "new" }
          format.json { render json: @image.errors, status: :unprocessable_entity }
        end
      end
      
    end
  end

  # PUT /images/1
  # PUT /images/1.json
  def update
    @image = Image.find(params[:id])    
    if @image.fname != params[:image]['fname']
      /(.*)\.(jpg|png)/i.match(@image.fname)
      iname = $1
      iformat = $2    
      paths = "originals", "75x75", "image_thumb"
      paths.each do |subdir|
        Dir.chdir("#{Rails.root}/#{@image.path}/#{subdir}")
        file1 = File.open(@image.fname, "r")          
        file2 = File.open(params[:image]['fname'], "w")
        file1.each {|line| file2.puts(line)}
        File.unlink(@image.fname)
      end

    end
    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to @image, notice: "Image was #{params[:image]['fname']} successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
#    @image = Image.find(image_id)
    @image = Image.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Images deleted' }
      format.json { head :no_content }
    end
  end
end
