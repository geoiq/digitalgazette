module ApplicationHelper

  
  
  # used for api links
  # TODO this is more or less a dummy used only for digitalgazette
  def from_api model, action, param=nil
    raise "nothing else than maps are supported here" unless model == :map
    case action
    when :new
      "#{API::MAP::MAKER::NEW}"
    when :show
      render :partial => 'maps/embed', :locals => { 
        :host => API::MAP::HOST
      }

    when :edit
     raise "params[:id] reqiored for action :edit" unless param
     "#{API::MAP::MAKER::EDIT.first}#{param}#{API::MAP::MAKER::EDIT.last}"
    else
      raise "unsupported api call"
    end
  end
  
  def page_line page, &block
    "<li class='small_icon #{page.icon}%>_16'>#{yield}</li>"
  end

  # TODO: think about patching this in core
  # there was no possibility to pass :method => 'get' to pagination links
  def pagination_for(things, options={})
    return if !things.is_a?(WillPaginate::Collection)
    if request.xhr?
      defaults = {:renderer => LinkRenderer::Ajax, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2, :method => 'get'}
    else
      defaults = {:renderer => LinkRenderer::Dispatch, :previous_label => "&laquo; %s" % I18n.t(:pagination_previous), :next_label => "%s &raquo;" % I18n.t(:pagination_next), :inner_window => 2}
    end
    will_paginate(things, defaults.merge(options))
  end

  # i had problems, this does exactly, what i want 
  def better_hidden_field group, name, value
   "<input type='hidden' id='#{group}_#{name}' name='#{group}[#{name}]' value='#{value}' />"

  end
  
  
end
