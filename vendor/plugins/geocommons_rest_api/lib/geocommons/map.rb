class Geocommons::Map < Geocommons::BasePage
  geocommons_service :maker
  geocommons_model 'Map'

  attributes :short_classification, :author, :title, :id, :tags, :pk, :type, :description, :permissions, :link, :bbox, :created, :link, :layers

  def author_name
    author['name']
  end

  def author_url
    author['url']
  end

  def author
    @author || { }
  end

  def url
    "/maps/#{id}"
  end

  def layers
    @layers.map { |data|
      Geocommons::Overlay.new(data)
    }
  rescue
    []
  end
end
