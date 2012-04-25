class SiteController < ApplicationController
  layout "main"
  skip_before_filter :authorize
  def index
    @table_cells = Hash.new
    @cat_thumbs = Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
    cthumb = ""
    @categories_number = Category.all.count
    @row_number = (((@categories_number/2).to_i)+1)
    
    Category.all.each do |ff|
      Gallery.where(:category_id => ff.id).each do |ss| 
        ct = Image.where(:gallery_id => ss.id, :gthumb => true).all(:limit => 1, :order => 'random()')
        ct.each do |cth|
          /(.*)\.jpg|png/i.match(cth.fname)
          iname = $1
          cthumb = "../#{cth.path}/category_thumb/#{iname}.png"
        end
      end
      while(1) do 
        key1 = rand(1..3)
        key2 = rand(1..@row_number)
        if @cat_thumbs[key1][key2] == {}
          @cat_thumbs[key1][key2] = "#{cthumb}:#{ff.id}"
          break
        end
      end

    end  

  end

end
