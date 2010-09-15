module Geocommons
  class BasePage < Crabgrass::ExternalPage
    def self.inherited(base)
      base.extend(Geocommons::FindMethods)
      base.extend(Geocommons::Pagination)
      base.send(:include, Geocommons::Attributes)
    end
  end
end
