class Geocommons::Map < Geocommons::BasePage
  geocommons_service :maker
  geocommons_model 'Map'

  attributes :short_classification, :author, :title, :id, :tags, :pk, :type, :description, :permissions, :link, :bbox, :created

  # TODO move this to geocommons.yml
  Crabgrass::ExternalAPI.register('map',
                                  { :model => self.class.name,
                                    :methods =>
                                    { :find => "paginate"},
                                    :query_builder => {
                                      :keywords => {
                                        "text" => "",
                                        "tag" => "tag"
                                      },
                                      :argument_separator => " ",
                                      :key_value_separator => ":"
                                    }
                                  }
                                )

  def id
    # GeoCommons formats id as Map:123
    @id.kind_of?(String) ? @id.split(':').last.to_i : @id
  end

  def author
    @author || { }
  end
end
