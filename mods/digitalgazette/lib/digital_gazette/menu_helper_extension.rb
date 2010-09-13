module DigitalGazette
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
end
