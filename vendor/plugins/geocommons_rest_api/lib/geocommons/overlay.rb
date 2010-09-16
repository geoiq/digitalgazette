require File.dirname(__FILE__) + '/../crabgrass/external_page'
require File.dirname(__FILE__) + '/../crabgrass/external_api'
require File.dirname(__FILE__) + '/../geocommons/base_page'
require File.dirname(__FILE__) + '/../geocommons/find_methods'
require File.dirname(__FILE__) + '/../geocommons/attributes'
require File.dirname(__FILE__) + '/../geocommons/pagination'

module Geocommons
  class Overlay < BasePage
    geocommons_service :finder
    geocommons_model 'Overlay'

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
