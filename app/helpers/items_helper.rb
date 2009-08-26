module ItemsHelper

  # Rating an item
	#
	# This helper method will return the Javascript elements allowing to rate an item.
  # 
  # Parameters :
  # - object: Item instance
  # - rerate: Boolean value (true or false)
  # - onRate: Ajax Request to Store Rating with parameters
  # - locked: true or false to lock or unlock rating on item
	# 
	# Usage :
  # <tt>item_rate(@current_object)</tt>
  def item_rate(object, params = {})
    params ||= {
      :rerate => false,
  		:onRate => "function(element, info) {
  			new Ajax.Request('#{rate_item_path(object)}', {
  				parameters: info
  			})}"
    }
    params_to_js_hash = '{' + params.collect { |k, v| "#{k}: #{v}" }.join(', ') + '}'
    div_id = "rating_#{object.class.to_s.underscore}_#{object.id}_#{rand(1000)}"
    content_tag(:div, nil, { :id => div_id, :class => :rating }) +
      javascript_tag(%{
			new Starbox("#{div_id}", #{object.rates_average}, #{params_to_js_hash});
      })
  end

  # Rating Item Locked
  #
	# This helper method will return the Javascript element defining the rate of the item.
	#
	# Parameter :
	# - object: Item instance
	#
  # Usage :
  # <tt>item_rate_locked(article_object)</tt>
  def item_rate_locked(object)
    item_rate(object, :locked => true)
  end

	# Override of ActsAsItem helper method
	#
  # This method will override the method used in popup of fckeditor to display the item :
  # link on title for article, link on image for image, ...
	#
	# Parameters :
	# - url: String defining the url to get the resource to link to
	# - object: Item instance
	#
	# Usage :
	# item_display_for_pop_up(@image.url, @image)
  def item_display_for_pop_up(url, object)
    link_to_function object.title, "javascript:SelectFile('" + url + "')"
  end


	# Form for Item instance (Common fields)
  #
	# This helper method will render the partial items/_form.html.erb and passed
	# some parameters to it link the block to bind to that form.
	#
  #  Parameters :
  #  object: Instance of an Item object
  #  title : String defining the form title
  #  &block : Block to bind to the partial for specific fields of that item object
	#
	# Usage :
  # <tt>form_for_item article_object, title do |f| </tt>
  # <tt>end</tt>
  def form_for_item(object, title = '', &block)
		concat(render(:partial => "items/form", :locals => { :block => block, :title => title }), block.binding)
  end

	 

	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
      :locals => {  :object => parameters[:object],
        :title => parameters[:title],
        :block => block                 } ),
      block.binding
  end
  
	# FCKEditor field initialisation
  #
	# This helper method will define the different Javascript settings needed by FCKeditor text area field
	# defined in the blank_form_builder.rb initializer.
	#
	# Parameters :
	# - object: Item instance
	# - attribute: String defining the instance attribute to configure for FCKeditor
	#
  # Usage :
  # f.advanced_editor(:body, 'Article' + ' * :')
	def advanced_editor_on(object, attribute)
    '<script type="text/javascript" src="/fckeditor/fckeditor.js"></script>' +
      javascript_tag(%{
        var oFCKeditor = new FCKeditor('#{object.class.to_s.underscore}_#{attribute}', '730px', '350px') ;
        oFCKeditor.BasePath = "/fckeditor/" ;
				oFCKeditor.Config['ImageUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Image";
 				oFCKeditor.Config['FlashUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Video";
				oFCKeditor.Config['LinkUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Link";
        oFCKeditor.Config['DefaultLanguage'] = '#{I18n.locale.split('-')[0]}' ;
        oFCKeditor.ReplaceTextarea() ;
        
      })
  end
	
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

  # Items List
  #
  # Usage:
  #
  # <tt>display_items_list(items_list, ajax_url)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  # - ajax_url: ajax item path for the item_type
	def display_items_list(items_list, ajax_url, partial_used='items/items_list')
	  content = render :partial => partial_used, :locals => { :ajax_url => ajax_url }
		return content_tag(:div, content, :id => "object-list")
	end

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_in_list(items_list)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  def display_item_in_list(items_list, partial_used='items/item_in_list')
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Display Item in List for Editor
	def display_item_in_list_for_editor
		display_item_list('items/item_in_list_for_editor')
	end

  # Classify Bar for Ordering, Filtering Items
  # 
  # Usage:
  # 
  # <tt>display_classify_bar(['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'], ajax_url, 'object-list')</tt>
  # 
  # will return classify bar for item list with option to filter on fields
  # 
  # Parameters:
  # 
  # - ordering_fields_list: 'created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'
  # - ajax_url: url to be passed to be called on click of item
  # - refreshed_dv: objects-list
  # - partial_used : 'items/classify_bar'
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='items/classify_bar')
		render :partial => partial_used, :locals => {
      :ordering_fields_list => ordering_fields_list,
      :ajax_url => ajax_url,
      :refreshed_div => refreshed_div
		}
	end

  # Ajax Item Path
  #
  # Usage:
  #
  # <tt>get_ajax_item_path('article')</tt>
  # 
  # Will return the ajax_items_path depending on the current_worksapces
  def get_ajax_item_path(item_type)
    item_type ||=  get_allowed_item_types(current_workspace).first.pluralize
    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    return url
  end

  # Safe Url for Classify Bar
	def safe_url(url, params)
		# TODO generic allowing to replace params in url
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
		return (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')

#    return url+'/?'+params.join('&')
	end

  # Render Specific Partial according to Item Type passed
  #
  # Usage get_specific_partial('article', preview, article_object)
  #
  # will render the partial depending on the item_type
  def get_specific_partial(item_type, partial, object)
    if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
      render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
    else
      render :nothing => true
    end
  end

	# Workspaces checkboxes for item form
  #
  # Usage:
  #
  # <tt>item_status_fields(form, article)</tt>
  #
  # will return all the checkboxes linked to workspaces for that item, with the different options set (disabled, checked or hidden)
	def item_workspaces_checkboxes(form, item)
		strg = ""
		item_class_name = item.class.to_s.underscore
		check_box_tag_name = "#{item_class_name}[associated_workspaces][]"
		res=[]
		# Workspace list allowing user to add new item and accepting items of that type
		list = (res + Workspace.allowed_user_with_permission(@current_user.id, item_class_name+"_new")).uniq.delete_if{ |w| !w.ws_items.to_s.split(',').include?(item_class_name) }
		#
		if (list.size > 1 || @current_user.has_system_role('superadmin'))
			strg += "<label>#{I18n.t('general.object.workspace').camelize+'(s) :'}</label><div class='formElement'>"
			#form.field(:workspaces, :label => I18n.t('general.object.workspace').camelize+'(s) :', :ajax => false)
			list.collect do |w|
				# Setting the checked status form that workspace
				if params[item.class.to_s.downcase] && params[item.class.to_s.downcase][:associated_workspaces]
           checked = params[item.class.to_s.downcase][:associated_workspaces].include?(w.id.to_s)
				else
           checked = Item.exists?(:workspace_id => w.id, :itemable_id => item.id, :itemable_type => item.class.to_s)
				end
				# Creating the checkboxes
				if ((w.state == 'private') && (w.creator_id == @current_user.id) && (item.new_record? || item.user_id==@current_user.id)) || (list.size==1) || (w == current_workspace)
					strg += check_box_tag(check_box_tag_name, w.id, true, :disabled => true, :class => 'checkboxes') + ' ' + w.title + hidden_field_tag(check_box_tag_name, w.id.to_s) + '<br />'
				else
					strg += check_box_tag(check_box_tag_name, w.id, checked, :class => 'checkboxes') + ' ' + w.title + '<br />'
				end
			end
			strg += '</div>'
		elsif (list.size > 0)
			list.each do |ws|
				strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
			end
		end
		(item.workspaces - list).each do |ws|
			strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
		end
		return strg
	end

end