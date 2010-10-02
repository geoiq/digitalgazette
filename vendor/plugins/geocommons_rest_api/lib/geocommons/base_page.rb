module Geocommons
  class BasePage < Crabgrass::ExternalPage
    def self.inherited(base)
      base.extend(Geocommons::FindMethods)
      base.extend(Geocommons::Pagination)
      base.send(:include, Geocommons::Attributes)
    end

    def user

    end

    def id
      # GeoCommons formats id as Map:123
      @id.kind_of?(String) ? @id.split(':').last.to_i : @id
    end

    # FIXME: do we get a "updated" attribute from geocommons?
    def updated_at
      (DateTime.parse(created) if created) || Time.now
    end

    def created_at
      (DateTime.parse(created) if created) || Time.now
    end

    def updated_by
      contributor ? contributor : author
    end

    def created_by
      author || ""
    end
  end
end
