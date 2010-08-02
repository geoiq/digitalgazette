module DigitalGazette
  module PageExtension
    def self.included(base)
      base.instance_eval do
        extend(DigitalGazette::PageExtension::ClassMethods)

        # acts_as_solr :fields => [
        #                          { :title => { :boost => 4.0 } },
        #                          :data_id,
        #                          { :summary => { :boost => 2.0 } },
        #                          { :tags => { :boost => 6.0 } },
        #                          :owner_name,
        #                          :created_at,
        #                          :public
        #                         ]

        before_save :combine_methodologies
      end
    end

    module ClassMethods
      def popular(type = "Page", limit = 5)
        begin
          type.constantize.find_by_solr("*", :limit => limit).docs
        rescue
          []
        end
      end

      def recent(type = "Page", limit = 5)
        begin
          type.constantize.find_by_solr("*", :limit => limit,:order => 'created_at_t asc').docs
        rescue
          []
        end
      end
    end

    def combine_methodologies
      self.methodology = self.methodologies.join(METHODOLOGY_SPLIT)
    end

    # TODO: make this more code generation than explicit - ajturner

    METHODOLOGY_SPLIT = ","

    def methodologies
      @methods ||= (self.methodology || "").split(METHODOLOGY_SPLIT)
    end

    def research_report
      !self.methodologies.blank?
    end

    def research_report=(setting)
      # thanks, nothing to see here - just for the UI.
    end

    def methodology_focusgroups
      return true if self.methodologies.include?("focusgroups")
    end

    def methodology_focusgroups=(setting)
      if(setting == true || setting.to_i == 1)
        self.methodologies << "focusgroups"
      else
        self.methodologies.delete("focusgroups")
      end

    end

    def methodology_interviews
      return true if self.methodologies.include?("interviews")
    end

    def methodology_interviews=(setting)
      if(setting == true || setting.to_i == 1)
        self.methodologies << "interviews"
      else
        self.methodologies.delete("interviews")
      end
    end

    def methodology_survey
      return true if self.methodologies.include?("survey")
    end

    def methodology_survey=(setting)
      if(setting == true || setting.to_i == 1)
        self.methodologies << "survey"
      else
        self.methodologies.delete("survey")
      end
    end

    def methodology_opensource
      return true if self.methodologies.include?("opensource")
    end

    def methodology_opensource=(setting)
      if(setting == true || setting.to_i == 1)
        self.methodologies << "opensource"
      else
        self.methodologies.delete("opensource")
      end
    end

    def methodology_unknown
      return true if self.methodologies.include?("unknown")
    end

    def methodology_unknown=(setting)
      if(setting == true || setting.to_i == 1)
        self.methodologies << "unknown"
      else
        self.methodologies.delete("unknown")
      end
    end
  end
end
