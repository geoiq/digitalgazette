# These are page related helpers that might be needed anywhere in the code.
# For helpers just for page controllers, see base_page_helper.rb

module PageHelper
  def cover_for(page)
    if page.cover    
      thumbnail_img_tag(page.cover, :medium, :scale => '74x96', :plugin => "digitalgazette") 
    else
      image_tag(clean_name_for(page).downcase + ".png", :plugin => "digitalgazette", :alt => "Thumbnail for #{clean_name_for(page)}")
    end
  end

  # page url with the support to link to external
  # ressources
  #
  # supported classes must specify .url
  def page_url_for page
    if external?(page)
      page.url rescue raise("page.url not specified")
    else
      page_url(page)
    end
  end
  
  # need this for support of namespaced external resources
  def clean_name_for page
    page.class.name.to_s.split("::").last
  end

  
  
  #
  # NOTE this is really really coupled and complicated in core
  # - trying to fix something, that maybe should be solved somewhere else --suung      
   
  
  # *NEWUI
  #
  # helper to show the information box of a page
  #
  # TODO clean up this method!
  def page_information_box_for(page, options={})
    locals = {:page => page}

    # status, date and username
    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
    is_new = field == 'updated_at'
    status    = is_new ? I18n.t(:page_list_heading_updated) : I18n.t(:page_list_heading_new)
    if external?(page)
      username = I18n.t(:dg_external_user) #page.updated_by #TODO GC gives us strange users
      locals.merge!(:tags => (page.tags))
    else
      username = link_to_user(page.updated_by_login)
    end   
    date     = friendly_date(page.send(field))
    locals.merge!(:status => status, :username => username, :date => date)

    if options.has_key?(:columns)
      locals.merge!(:views_count => page.views_count) if options[:columns].include?(:views)
      if options[:columns].include?(:stars)
        star_icon = page.stars_count > 0 ? icon_tag('star') : icon_tag('star_empty')
        locals.merge!(:stars_count => content_tag(:span, "%s %s" % [star_icon, page.stars_count]))
      end
      locals.merge!(:contributors =>  content_tag(:span, "%s %s" % [image_tag('ui/person-dark.png'), page.stars_count])) if options[:columns].include?(:contributors)
      

    end

    render :partial => 'pages/information_box', :locals => locals
  end
  
  
  def notices_for(page)
    if external?(page)
      notices = [{ :external_user => page.author, :date => page.updated_at}] # TODO this can cause problems with other models than GeoCommons
    else
      notices = page.flag[:user_participation].try.notice
    end
    if notices.any?
      render :partial=>'pages/notice', :collection => notices
    end
  end

  def page_notice_message(notice)
    if notice[:user_login]
      sender = User.find_by_login notice[:user_login]
    elsif notice[:external_user]
      sender = notice[:external_user]
    else
      sender = nil
    end
    date = friendly_date notice[:time]
    html = I18n.t(:page_notice_message, :user => link_to_user(sender), :date => date)
    if notice[:message].any?
      notice_message_html = ":<br/> &ldquo;<i>%s</i>&rdquo;" % h(notice[:message])
      html += ' ' + I18n.t(:notice_with_message, :message => notice_message_html)
    end
    html
  end

  # NOTE there must be a better way t combine tags and preferred
  def tag_path_with_preferred(tag,preferred)
    if preferred
      "/search/preferred/#{preferred}/tag/#{tag.downcase}/"
    else
      "/search/tag/#{tag.downcase}/"
    end
  end 
  
  def external?(page)
    EXTERNAL_PAGE_TYPES.include?(clean_name_for(page).downcase)
  end
  

  
  
end
