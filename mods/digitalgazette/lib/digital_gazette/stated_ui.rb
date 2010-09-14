module DigitalGazette
  # Used to store information about
  # * what is shown
  # * which page is shown
  # other options used in stateful widgets
  #
  #
  module StatedUI
    
    def self.included(base)
      base.class_eval do
        before_filter :load_ui_state
      end
    end
    
    def load_ui_state
      @@ui_state = session[:ui_state] ||= { }
    end
  
    def ui_state
      @ui_state
    end
    
    def export_ui_state
      ui_state.to_json
    end
    
    # OPTIONS 
    #
    # page => 1,2,3,4
    # state => 1 | 0 (open/closed)
    # children => {:other_widgets}
    # 
    def set_ui_state_for widget, options
      session[:ui_state][widget] = options
    end
  
  end
end
