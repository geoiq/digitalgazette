class ApplicationController < ActionController::Base

  helper_method :api_for  
  # returns the right api for a model, currently hardcoded
  def api_for model
    raise "not supported" unless model.to_sym == :map
    DigitalGazette::Api.new(:map)
  end
  
end
