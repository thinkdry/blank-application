module ContentHelper

  # Dislay of the given item type in content tabs list
  #
	# This helper method gets the item list to display,
	# and generates the HTML code displaying that list,
	# inside a content tabs list.
  #
  # Parameters :
  # - item_type: String defining the item type to display
  # - items_list: 
  # - ajax_url: ajax item path for the item_type
	# 
	# Usage :
  # display_tabs_items_list('article', paginated_objects, ajax_items_path('article'))
  def display_tabs_items_list(item_type, items_list, ajax_url)
		item_types = get_allowed_item_types(current_workspace)
		item_type ||= item_types.first.to_s.pluralize
    content = String.new
		#raise item_types.inspect
		if item_type.blank?
			return I18n.t('item.common_word.no_item_types')
		else
			item_types.map{ |item| item.camelize }.each do |item_model|
     
        # each li got a different content
        li_content = String.new
        
				url = ajax_items_path(item_model.classify.constantize)
				item_page = item_model.underscore.pluralize
				options = {}
				options[:class] = 'selected' if (item_type == item_page)
				options[:id] = item_model.underscore

        tip_option = {}
        tip_option[:id] = "tip_" + item_model.underscore
        tip_option[:style] = "display:none;"
        tip_option[:class] = "tipTitle"
        
        li_content += link_to_remote(image_tag(item_model.classify.constantize.icon_48),:method=>:get, :update => "object-list", :url => url, :before => "selectItemTab('" + item_model.underscore + "')")
        li_content += content_tag(:div, item_model.classify.constantize.label , tip_option)
        li_content += "<script type='text/javascript'>
                      //<![CDATA[
                        new Tip('" + item_model.underscore + "',  $('tip_" + item_model.underscore + "'),
                            { effect: 'appear',
                              duration: 1,
                              delay:0,
                              hook: { target: 'topMiddle', tip: 'bottomMiddle' },
                              hideOn: { element: 'tip', event: 'mouseout' },
                              stem: 'bottomMiddle',
                              hideOthers: 'true',
                              hideAfter: 1,
                              width: 'auto',
                              border: 1,
                              offset: { x: 0, y: 3 },
                              radius: 0
                            });
                      //]]>
                    </script>"
				content += content_tag(:li,	li_content,	options)
			end
			return content_tag(:ul, content, :id => :tabs) + display_items_list(items_list, ajax_url)
		end
	end

end