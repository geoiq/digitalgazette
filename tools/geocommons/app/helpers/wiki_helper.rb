module WikiHelper
  def toolbar_create_map_function(wiki)
    %(createMapFunction = function() {
      var editor = new HtmlEditor(#{wiki.id});
      editor.saveSelection();
      #{modalbox_function(map_popup_show_url(@wiki), :title => I18n.t(:add_map))};
    })
  end
  
  def map_popup_show_url(wiki)
    if @page and @page.data and @page.data == wiki
      page_xurl(@page, :action => 'map_popup_show', :wiki_id => wiki.id)
    else
      url_for(wiki_action('map_popup_show', :wiki_id => wiki.id).merge({:escape => false}))
    end
  end  
end