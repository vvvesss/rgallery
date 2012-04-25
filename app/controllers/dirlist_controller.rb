require 'will_paginate/array'

class DirlistController < ApplicationController
  def index
    Dir.mkdir("#{Rails.root}/public") if ! File.directory?("#{Rails.root}/public")
    Dir.mkdir("#{Rails.root}/public/images") if ! File.directory?("#{Rails.root}/public/images")
    Dir.mkdir("#{Rails.root}/public/images/tmp") if ! File.directory?("#{Rails.root}/public/images/tmp")  
    @path = "#{Rails.root}/public/images/tmp" #default upload path
    Dir.chdir(@path)
    @perpage = 10
    @perpage = params[:perpage].to_i if params[:perpage]
    session[:percentage] = params[:perpage].to_i if params[:perpage]
    #@imglist = Dir["*.{JPG,PNG,jpg,png}"]
    @imglist = Dir["*.{JPG,PNG,jpg,png}"].paginate page: params[:page], order: 'created_at desc', per_page: @perpage
    @galleries = Gallery.order(:title)
    @note = ""
    #Image.delete_all
    if (params[:files] and params[:gal]) 
      imgdir = "#{Time.now.strftime("%Y%m%d")}#{rand(100000..200000)}" #make dateRandom dir
      params[:files].each do |file|
	begin
          Dir.mkdir("../#{imgdir}") if ! File.directory?("../#{imgdir}")
          Dir.mkdir("../#{imgdir}/galery_thumb") if ! File.directory?("../#{imgdir}/galery_thumb")
          Dir.mkdir("../#{imgdir}/category_thumb") if ! File.directory?("../#{imgdir}/category_thumb")          
          Dir.mkdir("../#{imgdir}/image_thumb") if ! File.directory?("../#{imgdir}/image_thumb")
          Dir.mkdir("../#{imgdir}/75x75") if ! File.directory?("../#{imgdir}/75x75")
          Dir.mkdir("../#{imgdir}/originals") if ! File.directory?("../#{imgdir}/originals")
          if !File.exists?("../#{imgdir}/#{file}")
          
             /(.*)\.(jpg|png)/i.match(file)
             iname = $1
             iformat = $2

            #make gallery thumbs
            g_thumb = Magick::Image.read(file).first
            thumb_title = @galleries.find(params[:gal]).title
            cat_id = @galleries.find(params[:gal]).category_id
            cat_title = Category.find(cat_id).title

            #create thumb image_thumb     
            g_thumb.change_geometry!('200x150') { |cols, rows, img|
              g_thumb.resize!(cols, rows)
            }
            g_thumb.write("../#{imgdir}/image_thumb/#{iname}.#{iformat}")
            
            #create thumb 75x75
            g_thumb.crop_resized!(75, 75, Magick::NorthGravity)
            g_thumb.write("../#{imgdir}/75x75/#{iname}.#{iformat}")

            if params[:thumb_files].kind_of?(Array)
              if params[:thumb_files].include?(file) 
                #create polaroid effect gallery thumbnail 
                g_thumb = Magick::Image.read("../#{imgdir}/image_thumb/#{iname}.#{iformat}").first
                g_thumb[:caption] = thumb_title
                sign = rand(1..2);
                sign == 1 ? randint = "-#{rand(15)}" : randint = rand(15) 
                g_thumb = g_thumb.polaroid(randint.to_i) { 
                  self.gravity = Magick::CenterGravity 
                  self.pointsize = 18
                  self.font_family = "Courier"
                }              
                g_thumb.write("../#{imgdir}/galery_thumb/#{iname}.png")
  
                c_thumb = Magick::Image.read("../#{imgdir}/image_thumb/#{iname}.#{iformat}").first
                c_thumb[:caption] = cat_title
                c_thumb = c_thumb.polaroid(randint.to_i) { 
                  self.gravity = Magick::CenterGravity 
                  self.pointsize = 18
                  self.font_family = "Courier"
                }
                c_thumb.write("../#{imgdir}/category_thumb/#{iname}.png") 
              end  
            end


            #move and delete if needed image files
            file1 = File.open(file, "r")          
            file2 = File.open("../#{imgdir}/originals/#{file}", "w")
            file1.each {|line| file2.puts(line)}

            File.unlink("#{@path}/#{file}") if params[:del] 
          else
            @note += "File #{file} already exists in ../#{imgdir}!" 
          end
        rescue => e
          @note += "Error: Rescued Exception on moving files! -> #{e.message}" 
          next;
        end
        @note += "File #{file} added to Gallery #{params[:gal]}!" 
        
        #save images to database model
        image = Image.new
        image.fname = "#{file}"
        image.path = "images/#{imgdir}"
        if params[:thumb_files].kind_of?(Array) 
          image.gthumb = true if params[:thumb_files].include?(file)
        end
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
