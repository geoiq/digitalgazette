# PublicHome

class MenuListener < Crabgrass::Hook::ViewListener
   include Singleton

   def top_menu(context)
      render :partial => '/root/navbar_item', :collection => context[:group].menu_items unless context[:group].nil? 
   end
 end
