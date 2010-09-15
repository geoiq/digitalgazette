require File.dirname(__FILE__) + '/../crabgrass/external_page'
require File.dirname(__FILE__) + '/../crabgrass/external_api'
module Geocommons
  class Overlay < BasePage
    geocommons_service :finder
    geocommons_model 'Overlay'

    # TODO move this to geocommons.yml
    Crabgrass::ExternalAPI.register('overlay',
                                    {                                                                         :model => self.class.name,
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

    def initialize(params={})
      params.each_pair do |k, v|
        instance_variable_set("@#{k}", v) if VALID_ATTRIBUTES.include?(k)
      end
    end
    attributes %w(short_classification name can_view can_edit
                  author can_download published icon_path id
                  contributor tags layer_size link description
                  source bbox created overlay_id detail_link)

    def id
      overlay_id
    end

    def cover
      if icon
        file = open(icon)
        def file.original_filename
          File.base_name(icon)
        end
        Asset.build(:uploaded_data => file)
      end
    end

    def updated_at
      created.to_datetime
    end

    def created_at
      created.to_datetime
    end

    def updated_by
      contributor ? contributor : author
    end

    def created_by
      author || ""
    end

    def icon
      icon_path
    end

    def title
      name && !name.empty? ? name : description.truncate(30)
    end

    def url
      detail_link
    end
  end
end
