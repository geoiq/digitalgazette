# These are page related helpers that might be needed anywhere in the code.
# For helpers just for page controllers, see base_page_helper.rb

module PageHelper
  def cover_for(page)
    if page.cover    
      thumbnail_img_tag(page.cover, :medium, :scale => '96x96') 
    else
      image_tag(page.class.name.downcase + ".png", :plugin => "digitalgazette", :alt => "Thumbnail for #{page.class.name}")
    end
  end
end