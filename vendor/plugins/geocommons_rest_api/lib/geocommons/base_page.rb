module Geocommons
  class BasePage < Crabgrass::ExternalPage
    def self.inherited(base)
      base.extend(Geocommons::FindMethods)
      base.extend(Geocommons::Pagination)
      base.send(:include, Geocommons::Attributes)
    end

    # FIXME: do we get a "updated" attribute from geocommons?
    def updated_at
      DateTime.parse(created) if created
    end

    def created_at
      DateTime.parse(created) if created
    end

    def updated_by
      contributor ? contributor : author
    end

    def created_by
      author || ""
    end
  end
end
