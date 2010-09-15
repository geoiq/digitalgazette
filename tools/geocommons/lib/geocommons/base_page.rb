module Geocommons
  class BasePage < Crabgrass::ExternalPage
    def self.inherited(base)
      base.extend(Geocommons::FindMethods)
      base.extend(Geocommons::Pagination)
      base.send(:include, Geocommons::Attributes)
    end

    def updated_at
      DateTime.parse(created)
    end

    def created_at
      DateTime.parse(created)
    end

    def updated_by
      contributor ? contributor : author
    end

    def created_by
      author || ""
    end
  end
end
