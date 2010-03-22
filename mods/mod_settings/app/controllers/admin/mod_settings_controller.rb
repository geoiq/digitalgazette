class Admin::ModSettingsController < Admin::BaseController
  def index
    @site = current_site
  end
end
