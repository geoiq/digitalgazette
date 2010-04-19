class AboutController < ApplicationController

  def show
    logger.info "!!!!! Method missing"
    render :template => "about/#{params[:id]}"
  rescue
    render :template => "not_found"
  end
end