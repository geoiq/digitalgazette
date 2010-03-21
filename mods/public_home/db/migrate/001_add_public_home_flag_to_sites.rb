class AddPublicHomeFlagToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :public_home, :boolean, :default => false
  end

  def self.down
    remove_column :sites, :public_home
  end
end
