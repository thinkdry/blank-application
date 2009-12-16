module Superadmin::SuperadminHelper
  
  def superadmin_tabs_generator ()
     #parsing the superadmin controllers directory
     controllers = Dir.new("#{RAILS_ROOT}/app/controllers/superadmin").entries
     content = String.new

     controllers.each do |controller|
       #if the current controller is realy a controller file (and not another ruby class)
       if controller =~ /_controller/ 

         #get the readable name of the controller. action_mailler_controller.rb should become Action mailer.
         controller_name_for_display = controller.gsub("_controller.rb","").humanize 
         #get the rails name of the controller.
         current_controller_name = controller.gsub("_controller.rb","")

         li_content = String.new
         #generate the url for the tab
  			 url = "/superadmin/" + current_controller_name
  			 #item_page = item_model.underscore.pluralize
  			 options = {}
  			 #get the selected controller for different display
  			 options[:class] = 'selected' if (controller_name == current_controller_name )

         #adding link to the good item tab
         li_content += link_to( controller_name_for_display, url, :class => 'munuElement')

         #creating the li element with link inside and corrects class and id
   			content += content_tag(:li,	li_content,	options)        
       end
     end
     #return a complete ul li structure.
     return content_tag(:ul, content, :id => :tabs) 
   end
end