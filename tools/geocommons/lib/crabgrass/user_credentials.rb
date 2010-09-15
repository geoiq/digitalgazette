# A module to handle credentials stored in the users table to use for external authentication
module Crabgrass::UserCredentials
  def self.included(base)
    base.send(:serialize, :external_credentials)
  end

  def external_credentials
    super || (external_credentials = { })
  end

  def credentials_for(service)
    external_credentials[service]
  end
end
