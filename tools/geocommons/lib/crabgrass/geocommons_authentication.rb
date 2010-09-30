# Provides a replacement for User#authenticated? to authenticate against the geocommons RestAPI instead.
module Crabgrass::GeocommonsAuthentication
  def self.included(base)
    base.send(:alias_method, :authenticated?, :authenticated_with_geocommons?)
  end

  def authenticated_with_geocommons?(password)
    if cookie = Geocommons::RestAPI.start_session(:core, login, password)
      self.external_credentials[:geocommons] ||= { }
      self.external_credentials[:geocommons][:session_cookie] = cookie
      save!
      true
    else false end
  end
end
