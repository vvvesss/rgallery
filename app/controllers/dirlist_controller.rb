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
          Dir.mkdir("../galery_thumb") if ! File.directory?("../galery_thumb")
          Dir.mkdir("#{imgdir}/image_thumb") if ! File.directory?("#{imgdir}/image_thumb")
          Dir.mkdir("#{imgdir}/75x75") if ! File.directory?("#{imgdir}/75x75")
          Dir.mkdir("#{imgdir}/originals") if ! File.directory?("#{imgdir}/originals")
          if !File.exists?("#{imgdir}/#{file}")
          
             /(.*)\.(jpg|png)/i.match(file)
             iname = $1
             iformat = $2

            #make gallery thumbs
            g_thumb = Magick::Image.read(file).first
            thumb_title = @galleries.find(params[:gal]).title

            #create thumb image_thumb     
            g_thumb.change_geometry!('300x200') { |cols, rows, img|
              g_thumb.resize!(cols, rows)
            }
            g_thumb.write("#{imgdir}/image_thumb/#{iname}.#{iformat}")
            
            #create thumb 75x75
            g_thumb.crop_resized!(75, 75, Magick::NorthGravity)
            g_thumb.write("#{imgdir}/75x75/#{iname}.#{iformat}")

            if params[:thumb_files].include?(file) 
              #create polaroid effect gallery thumbnail 
              g_thumb = Magick::Image.read("#{imgdir}/image_thumb/#{iname}.#{iformat}").first
              g_thumb[:caption] = thumb_title
              sign = rand(1..2);
              sign == 1 ? randint = "-#{rand(20)}" : randint = rand(20) 
              g_thumb = g_thumb.polaroid(randint.to_i) { 
                self.gravity = Magick::CenterGravity 
                self.pointsize = 25
              }


              g_thumb.write("../galery_thumb/#{iname}.png")
            end  
            


            #move and delete if needed image files
            file1 = File.open(file, "r")          
            file2 = File.open("#{imgdir}/originals/#{file}", "w")
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



end
