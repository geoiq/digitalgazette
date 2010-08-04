# Include hook code here

require 'ruby-debug'

self.load_once = false if RAILS_ENV =~ /development/
self.override_views = true

require 'digital_gazette/page_extension'

Dispatcher.to_prepare do
  
  #
  # NOTE this functionality is good for letting mods add
  #      arguments to PathFinder
  #
  # TODO find a good place for it in the core
  #
  # NOTE this is the only way to do this? ignore warnings
  # TODO think about making PATH_KEYWORDS unfrozen in core
  new_path_keywords = PathFinder::ParsedPath::PATH_KEYWORDS.dup
  new_path_keywords['preferred'] = 1
  PathFinder::ParsedPath::PATH_KEYWORDS = new_path_keywords.freeze
  
  module DigitalGazette

    module ControllerExtension::WikiPopupExtension
      def map_popup_show
        render :partial => 'wiki/map_popup', :locals => {:wiki => @wiki}
      end
    end

    ControllerExtension::WikiPopup.send(:include, ControllerExtension::WikiPopupExtension)

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

    GroupsController.send(:include, GroupsControllerExtension)

    module PagesControllerExtension
      def self.included(base)
        base.instance_eval do
          skip_before_filter :login_required
          before_filter :public_or_login_required, :except => [:search]
        end
      end

      def public_or_login_required
        return true unless @pages
        !(@pages.collect {|p| p.public? }.include?(false)) or login_required
      end
    end

    PagesController.send(:include, PagesControllerExtension)

    module SearchControllerExtension
      def self.included(base)
        base.instance_eval do
          skip_before_filter :login_required, :fetch_user, :login_with_http_auth
          # alias_method_chain :render_search_results, :digitalgazette
        end
      end

      # def render_search_results_with_digitalgazette
      #   @path.default_sort('updated_at') if @path.search_text.empty?
      #   @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params)))

      #   # if there was a text string in the search, generate extracts for the results
      #   if @path.search_text and @pages.any?
      #     begin
      #       add_excerpts_to_pages(@pages)
      #     rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
      #       RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
      #     end
      #   end

      #   full_url = search_url + @path
      #   handle_rss(:title => full_url, :link => full_url,
      #              :image => (@user ? avatar_url(:id => @user.avatar_id||0, :size => 'huge') : nil))
      # end
    end

    SearchController.send(:include, SearchControllerExtension)

    module WikiControllerExtension
      def self.included(base)
        base.instance_eval do
          before_filter :login_required, :except => [:show, :image_popup_show, :link_popup_show, :image_popup_upload, :map_popup_show]
        end
      end
    end

    WikiController.send(:include, WikiControllerExtension)

    module LayoutHelperExtension
      def custom_masthead_site_title
        content_tag :h2, link_to(current_site.title, '/')
      end

      def masthead_container
        locals = {}
        appearance = current_site.custom_appearance
        if appearance and appearance.masthead_asset and current_site.custom_appearance.masthead_enabled
          height = appearance.masthead_asset.height
          bgcolor = (appearance.masthead_background_parameter == 'white') ? '' : '#'
          bgcolor = bgcolor+appearance.masthead_background_parameter
          locals[:section_style] = "height: #{height}px"
          locals[:style] = "background-repeat: no-repeat; background-image: url(#{appearance.masthead_asset.url}); height: #{height}px;"
          locals[:render_title] = false
        else
          locals[:section_style] = ''
          locals[:style] = ''
          locals[:render_title] = true
        end
        render :partial => 'layouts/base/masthead', :locals => locals
      end

    end

    LayoutHelper.send(:include, LayoutHelperExtension)

    module MenuHelperExtension
      def top_menu(label, url, options={})
        id = options.delete(:id)
        menu_heading = content_tag(:span,
          link_to_active(label, url, options[:active]),
          :class => 'topnav'
        )
        content_tag(:span,
          [menu_heading, options[:menu_items]].combine("\n"),
          :class => ['menu', (options[:active] && 'current')].combine,
          :id => id
        )
      end

      def people_option
        top_menu(
          I18n.t(:menu_people),
          '/people/directory',
          :active => @active_tab == :people,
          :menu_items => current_user.is_a?(UnauthenticatedUser) ? [] : menu_items('boxes', {
            :entities => current_user.friends.most_active,
            :heading  => I18n.t(:my_contacts),
            :see_all_url => people_directory_url(:friends),
            :submenu => 'people'
          }),
          :id => 'menu_people'
        )
      end

      def groups_option
        top_menu(
          I18n.t(:menu_groups),
          group_directory_url,
          :active => @active_tab == :groups,
          :menu_items => current_user.is_a?(UnauthenticatedUser) ? [] : menu_items('boxes', {
            :entities => current_user.primary_groups.most_active,
            :heading => I18n.t(:my_groups),
            :see_all_url => group_directory_url(:action => 'my'),
            :submenu => 'groups'
          }),
          :id => 'menu_groups'
        )
      end

      def networks_option
        top_menu(
          I18n.t(:menu_networks),
          network_directory_url,
          :active => @active_tab == :networks,
          :menu_items => current_user.is_a?(UnauthenticatedUser) ? [] : menu_items('boxes', {
            :entities => current_user.primary_networks.most_active(@current_site),
            :heading => I18n.t(:my_networks),
            :see_all_url => network_directory_url(:action => 'my'),
            :submenu => 'networks'
          }),
          :id => 'menu_networks'
        )
      end

    end

    MenuHelper.send(:include, MenuHelperExtension)


    module SearchHelperExtension
      def mini_search_text_field_tag
        text_field_tag('search[text]', '', :id => "txtSearch", :class => 'search-box',
                       :size => 26,
                       :value => I18n.t(:search_input_caption),
                       :onfocus => hide_default_value,
                       :onblur => show_default_value)
      end
    end

    SearchHelper.send(:include, SearchHelperExtension)

    Page.send(:include, ::DigitalGazette::PageExtension)

    module UnauthenticatedUserExtension
      def groups
        []
      end

      def all_group_ids
        []
      end
    end

    UnauthenticatedUser.send(:include, UnauthenticatedUserExtension)


    # patches UserExtension::Groups
    module UserGroupsExtension
      def self.included(base)
        base.instance_eval do
          ## DIGITALGAZETTE: Don't order by default.
          has_many(:primary_groups, :class_name => 'Group', :through => :memberships,
                   :source => :group, :conditions => ::UserExtension::Groups::PRIMARY_GROUPS_CONDITION) do

            # most active should return a list of groups that we are most interested in.
            # this includes groups we have recently visited, and groups that we visit the most.
            def most_active
              max_visit_count = find(:first, :select => 'MAX(memberships.total_visits) as id').id || 1
              select = "groups.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
              find(:all, :limit => 13, :select => select)
            end
          end

          has_many(:primary_networks, :class_name => 'Group', :through => :memberships, :source => :group, :conditions => ::UserExtension::Groups::PRIMARY_NETWORKS_CONDITION) do
            # most active should return a list of groups that we are most interested in.
            # in the case of networks this should not include the site network
            # this includes groups we have recently visited, and groups that we visit the most.
            def most_active(site=nil)
              site_sql = (!site.nil? and !site.network_id.nil?) ? "groups.id != #{site.network_id}" : ''
              max_visit_count = find(:first, :select => 'MAX(memberships.total_visits) as id').id || 1
              select = "groups.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
              find(:all, :limit => 13, :select => select, :conditions => site_sql)
            end
          end
        end
      end
    end

    User.send(:include, DigitalGazette::UserGroupsExtension)

    # patches UserExtension::Users
    module UserUsersExtension
      def self.included(base)
        base.instance_eval do
          has_many :friends, :through => :relationships, :conditions => "relationships.type = 'Friendship'", :source => :contact do
          def most_active
            max_visit_count = find(:first, :select => 'MAX(relationships.total_visits) as id').id || 1
            select = "users.*, " + quote_sql([MOST_ACTIVE_SELECT, 2.week.ago.to_i, 2.week.seconds.to_i, max_visit_count])
            find(:all, :limit => 13, :select => select)
          end
        end
        end
      end
    end

    User.send(:include, DigitalGazette::UserUsersExtension)
  end
end

