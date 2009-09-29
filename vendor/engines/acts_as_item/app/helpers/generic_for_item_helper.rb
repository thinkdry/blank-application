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
  def item_rate(object, params=nil)
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
		concat(render(:partial => "generic_for_item/form", :locals => { :block => block, :title => title }), block.binding)
  end

	 

	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat\
      render( :partial => "generic_for_item/show",
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
	def advanced_editor_on(object, attribute, width, height)
    ws = current_workspace
		css_files = []
    ws ||= object.workspaces.delete_if{ |e| e.websites.empty? }.first if (object.class.to_s == "Page")
    if ws && ws.respond_to?(:websites) && ws.websites.first && (tmp=ws.websites.first.front)
        Dir["public/front_files/#{tmp.name}/stylesheets/*.css"].collect do |uploaded_css|
					css_files << "#{uploaded_css.split("public")[1]}"
				end
			end
#    css_files = '/fckeditor/css/test_fck.css' if css_files.empty?
     css_files = '/stylesheets/fckeditor.css' if css_files.empty?
    return '<script type="text/javascript" src="/fckeditor/fckeditor.js"></script>' +
      javascript_tag(%{
        var oFCKeditor = new FCKeditor('#{object.class.to_s.underscore}_#{attribute}', "#{ width }", "#{ height }") ;
        oFCKeditor.Config['EditorAreaCSS'] = "#{css_files}" ;
        oFCKeditor.BasePath = "/fckeditor/" ;
                                oFCKeditor.Config['ImageUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Image";
                                 oFCKeditor.Config['FlashUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Video";
                                oFCKeditor.Config['LinkUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.id}&type=Link";
        oFCKeditor.Config['DefaultLanguage'] = '#{I18n.locale.split('-')[0]}' ;
        oFCKeditor.ReplaceTextarea() ;
                        })
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
           checked = ItemsWorkspace.exists?(:workspace_id => w.id, :itemable_id => item.id, :itemable_type => item.class.to_s)
				end
				# Creating the checkboxes
				if ((w.state == 'private') && (w.creator_id == @current_user.id) && (item.new_record? || item.user_id==@current_user.id)) || (list.size==1) || (w == current_workspace)
					strg += check_box_tag(check_box_tag_name, w.id, true, :disabled => false, :class => 'checkboxes') + ' ' + w.title + hidden_field_tag(check_box_tag_name, w.id.to_s) + '<br />'
				else
					strg += check_box_tag(check_box_tag_name, w.id, checked, :class => 'checkboxes') + ' ' + w.title + '<br />'
				end
			end
			strg += '</div>'+ajax_error_message_on(item, 'items_workspaces')
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