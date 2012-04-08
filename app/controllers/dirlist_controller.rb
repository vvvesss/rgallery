class DirlistController < ApplicationController
  def index
    @path = "#{Rails.root}/images/tmp" #default upload path
    Dir.chdir(@path)
    @imglist = Dir["*.{jpg,png}"]
    @galleries = Gallery.order(:title)
    @note = ""
    #Image.delete_all
    if (params[:files] and params[:gal]) 
      params[:files].each do |file|
	begin
          imgdir = "../#{Time.now.strftime("%Y%m%d")}"
          Dir.mkdir(imgdir) if ! File.directory?(imgdir)
          Dir.mkdir("#{imgdir}/thumb") if ! File.directory?("#{imgdir}/thumb")
          Dir.mkdir("#{imgdir}/gthumb") if ! File.directory?("#{imgdir}/gthumb")
          if !File.exists?("#{imgdir}/#{file}")

            #make gallery thumbs
            #todo first resize then make effects!
            if params[:thumb_files].include?(file) 
		g_thumb = Magick::Image.read(file).first
		cols, rows = g_thumb.columns, g_thumb.rows
                thumb_title = @galleries.find(params[:gal]).title
                
                g_thumb[:caption] = thumb_title
                sign = rand(1..2);
                sign == 1 ? randint = "-#{rand(20)}" : randint = rand(20) 
                g_thumb = g_thumb.polaroid(randint.to_i) { 
                  self.gravity = Magick::CenterGravity 
                  self.pointsize = 25
                }
                

                #g_thumb.change_geometry!("#{cols}x#{rows}") do |ncols, nrows, img|
                #  img.resize!(ncols, nrows)
                #end
        	/(.*)\.(jpg|png)/i.match(file)
                g_thumb.write("#{imgdir}/gthumb/#{$1}.png")
            end
            
            #make thumbnail
            imagick = Magick::Image.read(file).first
            imagick.crop_resized!(75, 75, Magick::NorthGravity)
            imagick.write("#{imgdir}/thumb/#{file}")            

            #move and delete if needed image files
            file1 = File.open(file, "r")          
            file2 = File.open("#{imgdir}/#{file}", "w")
            file1.each {|line| file2.puts(line)}

            File.unlink("#{@path}/#{file}") if params[:del] 
          else
            @note += "File #{file} already exists in #{imgdir}!" 
          end
        rescue => e
          @note += "Error: Rescued Exception on moving files! -> #{e.message}" 
          next;
        end
        @note += "File #{file} added to Gallery #{params[:gal]}!" 
        
        #save images to database model
        image = Image.new
        image.fname = "#{file}"
        image.path = "images/#{Time.now.strftime("%Y%m%d")}"
        image.gthumb = true if params[:thumb_files].include?(file)
        image.gallery = Gallery.find(params[:gal])
        image.save

      end
      respond_to do |format|
        format.html { redirect_to dirlist_index_url, notice: "#{@note}" } 
        format.json { head :no_content }
      end      
    end
  end   



=begin    
    if params[:path]
      if (File.directory?(params[:path]))
	@pwd = Dir.pwd
        Dir.chdir(params[:path]) 
        @imglist = []
        @imglist = Dir["*.{jpg,png}"]
        @dirlist = []
        @dirlist = Dir.entries(params[:path]).sort
      else
        respond_to do |format|
          format.html { redirect_to dirlist_index_url, notice: "No such directory #{params[:path]}!" } 
          format.json { head :no_content }
        end
      end
    end
  end
=end

end
