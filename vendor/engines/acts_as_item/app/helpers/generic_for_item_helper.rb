module GenericForItemHelper


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
  def item_rate(item, disabled=nil)
    rated  = Rating.already_rated?(current_user, item)
    rating = item.rating.to_i
    str = ""
    if rated || disabled
      str = "<form id='submit_rating' method='post'>"
      (1..5).each do |i|
        str += "<input type='radio' class='star' name='rated' value='#{i}' disabled='disabled' #{(i == rating) ? "checked='checked'" : ''}/>"
      end
    else
      str = "<form id='submit_rating' action='#{rate_item_path(@current_object)}' method='post'>"
      (1..5).each do |i|
        str += "<input type='radio' class='auto-submit-star' name='rated' value='#{i}' #{(i == rating) ? "checked='checked'" : ''} />"
      end
    end
    str += "</form>"
    str
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
  def item_rate_locked(item)
    item_rate(item, true)
  end
  #
  #  def item_rate(object, params=nil)
  #    params ||= {
  #      :rerate => false,
  #  		:onRate => "function(element, info) {
  #  			new Ajax.Request('#{rate_item_path(object)}', {
  #  				parameters: info
  #  			})}"
  #    }
  #    params_to_js_hash = '{' + params.collect { |k, v| "#{k}: #{v}" }.join(', ') + '}'
  #    div_id = "rating_#{object.class.to_s.underscore}_#{object.id}_#{rand(1000)}"
  #    content_tag(:div, nil, { :id => div_id, :class => :rating }) +
  #      javascript_tag(%{
  #			new Starbox("#{div_id}", #{object.rates_average}, #{params_to_js_hash});
  #      })
  #  end

  

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
		concat(render(:partial => "generic_for_item/form", :locals => { :block => block, :title => title }))
  end



	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat(
      render( :partial => "generic_for_item/show",
        :locals => {  :object => parameters[:object],
          :title => parameters[:title],
          :block => block }))
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
    cn = current_container
		css_files = []
    #google_map = false
    #cn ||= object.send(current_container_type.pluralize).delete_if{ |e| e.websites.empty? }.first if (object.class.to_s == "Page")
    #IF THE WS IS A WEBSITE
    #TODO check for blanklight website
    
    if cn && cn.class == Website
      Dir["public/website_files/#{cn.title}/stylesheets/*.css"].collect do |uploaded_css|
        css_files << uploaded_css.split("public")[1]
      end
    end
    
    css_files << "/stylesheets/fckeditor.css" if css_files.empty?
    
    css_file_name = "&css_file_name[]=" + css_files.join(',') 

    field =  ''
    object.new_record? ? new_item = "&new=true" : new_item = ""
    field += '<script type="text/javascript" src="/ckeditor/ckeditor.js"></script>'
    field += '<script type="text/javascript">CKEDITOR.replace(\'ckInstance\', {customConfig : \'/admin/ck_config?' + new_item + css_file_name + '\'});</script>'
    return field
  end

	# Workspaces checkboxes for item form
  #
  # Usage:
  #
  # <tt>item_status_fields(form, article)</tt>
  #
  # will return all the checkboxes linked to workspaces for that item, with the different options set (disabled, checked or hidden)
	def item_containers_checkboxes(form, item, container)
		strg = ""
		item_class_name = item.class.to_s.underscore
		check_box_tag_name = "#{item_class_name}[associated_#{container.pluralize}][]"
		res=[]
		# Workspace list allowing user to add new item and accepting items of that type
		list = (res + container.classify.constantize.allowed_user_with_permission(@current_user, item_class_name+"_new", container)).uniq.delete_if{ |w| !w.available_items.to_s.split(',').include?(item_class_name) }
		if (list.size > 1 || @current_user.has_system_role('superadmin'))
			#form.field(:workspaces, :label => I18n.t('general.object.workspace').camelize+'(s) :', :ajax => false)
			list.collect do |w|
				# Setting the checked status form that workspace
				if params[item.class.to_s.downcase] && params[item.class.to_s.downcase]["associated_#{container.pluralize}".to_sym]
          checked = params[item.class.to_s.downcase]["associated_#{container.pluralize}".to_sym].include?(w.id.to_s)
				else
          checked = "items_#{container}".classify.constantize.exists?("#{container}_id".to_sym => w.id, :itemable_id => item.id, :itemable_type => item.class.to_s)
				end
				# Creating the checkboxes
				if ((w.state == 'private') && (w.creator_id == @current_user.id) && (item.new_record?)) || (w == current_container) || (w == @current_user.private_workspace) 
					#strg += check_box_tag(check_box_tag_name, w.id, true, :disabled => true, :class => 'checkboxes') + ' ' + w.title + '<br />'
					strg += hidden_field_tag(check_box_tag_name, w.id.to_s)
				else
					strg += check_box_tag(check_box_tag_name, w.id, checked, :class => 'checkboxes') + ' ' + w.title + '<br />'
				end
			end
			strg += ajax_error_message_on(item, "items_#{container.pluralize}")
		elsif (list.size > 0)
			list.each do |ws|
				strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
			end
		end
		(item.send(container.pluralize) - list).each do |ws|
			strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
		end
		return strg
	end

	def item_containers_select(form, item, container)
		str = ""
		if item.new_record?
			item_class_name = item.class.to_s.underscore
			select_tag_name = "#{item_class_name}[associated_workspaces][]"
			if current_container
				str += hidden_field_tag(select_tag_name, current_container.id.to_s)
			else
				str += "<label>#{I18n.t('general.object.workspace').camelize+'(s) :'}</label><div class='formElement'>"
				containers = container.classify.constantize.allowed_user_with_permission(@current_user, item_class_name+"_new", container).uniq.delete_if{ |w| !w.available_items.to_s.split(',').include?(item_class_name) }
				str += select_tag select_tag_name, options_for_select(containers.map{|w| [w.title, w.id]})
				str += '</div>'+ajax_error_message_on(item, "items_#{container.pluralize}")
			end
		end
		return str
  end

end

