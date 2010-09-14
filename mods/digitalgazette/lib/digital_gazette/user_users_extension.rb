module DigitalGazette
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
end
