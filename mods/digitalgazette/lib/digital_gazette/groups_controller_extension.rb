module DigitalGazette
  module GroupsControllerExtension
    def self.included(base)
      base.instance_eval do
        before_filter :login_required, :except => [:index, :show, :archive, :tags, :search, :pages, :people, :list_groups]
      end
    end

    def group_created_success
      flash_message :title => 'Group Created', :success => 'now make sure to configure your group'
      redirect_to groups_profiles_url(:action => 'edit')
    end
  end
end
