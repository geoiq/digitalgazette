module SearchHelper
  def mini_search_text_field_tag
    text_field_tag('search[text]', '', :id => "txtSearch", :class => 'search-box',
                                      :size => 26,
                                      :value => I18n.t(:search_input_caption),
                                      :onfocus => hide_default_value,
                                      :onblur => show_default_value)
  end
end
