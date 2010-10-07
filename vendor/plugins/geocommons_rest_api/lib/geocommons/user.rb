class Geocommons::User < UnauthenticatedUser
  attr :uri

  def initialize(geocommons_author)
    geocommons_author ||= { }
    @name = geocommons_author[:name] || ''
    @uri = geocommons_autor[:uri]
  end

  def display_name
    @name
  end
end
