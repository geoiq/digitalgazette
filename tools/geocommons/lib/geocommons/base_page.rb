module Geocommons
  class BasePage < Crabgrass::ExternalPage
    def self.inherited(base)
      base.extend(Geocommons::Finder)
    end
  end
end
