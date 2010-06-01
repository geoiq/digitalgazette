class AboutController < ApplicationController

  def show
    render :template => "about/#{params[:id]}"
  rescue
    render :template => "about/not_found"
  end
end