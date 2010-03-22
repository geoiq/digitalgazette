namespace :cg do

  desc "Sets the default for pages and group or network profiles to be public."
  task(:make_public => :environment) do
      Page.connection.execute "ALTER TABLE pages ALTER COLUMN public SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN membership_policy SET DEFAULT 1"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see_committees SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see_networks SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see_members SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_request_membership SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see_contacts SET DEFAULT true"
      Profile.connection.execute "ALTER TABLE profiles ALTER COLUMN may_see_groups SET DEFAULT true"
  end
end