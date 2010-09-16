class Geocommons::Map < Geocommons::BasePage
  geocommons_service :maker
  geocommons_model 'Map'

  attributes :short_classification, :author, :title, :id, :tags, :pk, :type, :description, :permissions, :link, :bbox, :created

  def id
    # GeoCommons formats id as Map:123
    @id.kind_of?(String) ? @id.split(':').last.to_i : @id
  end

  def author_name
    author['name']
  end

  def author_url
    author['url']
  end

  def author
    @author || { }
  end
end
