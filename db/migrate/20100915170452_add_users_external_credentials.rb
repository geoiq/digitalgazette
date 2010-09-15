class AddUsersExternalCredentials < ActiveRecord::Migration
  def self.up
    add_column :users, :external_credentials, :text
  end

  def self.down
    remove_column :users, :external_credentials
  end
end
