module DigitalGazette
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
end
