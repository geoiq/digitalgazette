# coming from map.layers
# {"title"=>"Census, Demographic Data For Manhattan, New York City", "subtitle"=>"Income over 100k", "styles"=>{"stroke"=>{"weight"=>2, "color"=>9478082, "alpha"=>1}, "fill"=>{"classificationType"=>"St Dev", "color"=>9478082, "selectedAttribute"=>"IncOver100", "classificationBreaks"=>[0, 5.6458, 91.4398, 177.2338, 263.0278, 875.7489], "categories"=>5, "colors"=>[9478082, 13685222, 16250871, 16704129, 16685353], "opacity"=>0.75}, "icon"=>{"size"=>1, "symbol"=>"propCircle", "color"=>9478082, "dropShadow"=>true, "lineStyle"=>"normal", "opacity"=>0.75}, "type"=>"CHOROPLETH"}, "type"=>"FinderData", "source"=>"finder:1982", "layer_id"=>1, "opacity"=>1.0, "visible"=>true}

module Geocommons
  class Overlay < Geocommons::BasePage
    geocommons_service :finder
    geocommons_model 'Overlay'

    attributes %w(short_classification name can_view can_edit
                  author can_download published icon_path id
                  contributor tags layer_size link description
                  source bbox created overlay_id detail_link title subtitle)
    alias_method :summary, :description

    def cover
      if icon
        file = open(icon)
        def file.original_filename
          File.base_name(icon)
        end
        Asset.build(:uploaded_data => file)
      end
    end

    def icon
      icon_path
    end

    def title
      @title || (name && !name.empty? ? name : description.truncate(30))
    end

    def url
      detail_link
    end

    def id_from_source
      source.split(":").last
    end

  end
end
