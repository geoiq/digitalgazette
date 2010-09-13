# Used to fake the original page behaviour
module Crabgrass
  class ExternalPage
    def method_missing(arg)
      if Page.instance_methods.include?(arg)
        logger.debug "missing #{arg} in #{self.class.name}"
        return ""
      end
    end
  end
end
