class Me::BaseController < ApplicationController
 
  before_filter :login_required
  stylesheet 'me'

  def index
    redirect_to :controller => 'me/dashboard'
  end
  
  def edit   
    if request.post? 
      if @user.update_attributes(params[:user])
        flash_message :success => 'Your profile was successfully updated.'
        redirect_to :action => 'edit'
      else
        flash_message_now :object => @user
      end
    end
  end

  protected
  
  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  before_filter :load_partials
  def load_partials
   @left_column = render_to_string :partial => 'me/sidebar'
  end

  # always have access to self
  def authorized?
    return true
  end
  
  def context
    me_context('large')
    unless ['show','index'].include?(params[:action])
      # url_for is used here instead of me_url so we can include the *path in the link
      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
      # that it is. regardless, we want it.)
      add_context params[:action], url_for(:controller => '/me/', :action => params[:action])
    end
  end
  
end
