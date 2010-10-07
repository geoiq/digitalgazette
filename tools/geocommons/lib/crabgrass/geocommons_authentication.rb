module Crabgrass::GeocommonsAuthentication
  def self.included(base)
    base.extend(ClassMethods)
    class << base
      alias_method :authenticate, :authenticate_with_geocommons
    end
  end

  def store_geocommons_cookie!(cookie)
    credentials_for(:geocommons)[:session_cookie] = cookie
    save!
    return self
  end

  module ClassMethods
    def authenticate_with_geocommons(login, password)
      if cookie = Geocommons::RestAPI.start_session(:core, login, password)
        User.for_geocommons(login, password).store_geocommons_cookie!(cookie)
      end
    end

    #
    #   User.for_geocommons(login)
    #   #=> new or existing user with given
    #       login & pw (latter not checked,
    #       just set in case of creation)
    # You need to save the user.
    def for_geocommons(login, pw)
      find_by_login(login) || new(:login => login, :password => pw,
                                  :password_confirmation => pw)
    end
  end
end
