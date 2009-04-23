module ItemsHelper

	 # Tag. Item's author is allowed to remove it by Ajax action.
  def item_tag tag, editable = false
    content = tag.name
    content += link_to_remote(image_tag('icons/delete.png'),
      :url => remove_tag_item_path(@current_object, :tag_id => tag.id),
      :loading => "$('ajax_loader').show()",
      :complete => "$('ajax_loader').hide()") if editable

    content_tag :span, content, :id => "tag_#{tag.id}"
  end

  def item_editable_tag tag
    item_tag tag, true
  end

  def item_rate(object, params = {})
    params = {
      :rerate => false,
  		:onRate => "function(element, info) {
  			new Ajax.Request('#{rate_item_path(object)}', {
  				parameters: info
  			})}"
  		} if params.empty?

    params_to_js_hash = '{' + params.collect { |k, v| "#{k}: #{v}" }.join(', ') + '}'
    div_id = "rating_#{object.class.to_s.underscore}_#{object.id}_#{rand(1000)}"

    content_tag(:div, nil, { :id => div_id, :class => :rating }) +
		javascript_tag(%{
			new Starbox("#{div_id}", #{object.rating}, #{params_to_js_hash});
		})
  end

  def item_rate_locked(object)
    item_rate(object, :locked => true)
  end

  # Container of tags that include modal window. Contains the javascript events.
  # Please apply 'hidden' class on each child you want to be displayed on mouseover.
  def item_reactive_content_tag(tag, object, &block)
    concat \
      content_tag(tag,
        render(:partial => "items/hidden_window", :object => object) + capture(&block),
        :id           => "item_#{object.object_id}",
        :class        => 'item',
        :onmouseover  => 'this.addClassName("over")',
        :onmouseout   => 'this.removeClassName("over")',
        :onclick      => "window.location.href = '#{item_path(object)}'"),
      block.binding
  end

	##################"

	# Define the common fields of the form of an item
  def form_for_item(object, title = '', &block)
		concat(render(:partial => "items/form", :locals => { :block => block, :title => title }), block.binding)
  end

	# Define the common information of the index of an item
#	def index_for_item
#		render(:partial => "items/index", :object => @current_objects)
#	end

	# Define the common information of the show of an item
	def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
  end
  
  # Define the common information of the show of an item
  def item_preview(parameters, &block)
    concat\
      render( :partial => "items/preview",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
  end

	# Form part for FCKEditor field
	def advanced_editor_on(object, attribute)
    '<script type="text/javascript" src="/fckeditor/fckeditor.js"></script>' +
    javascript_tag(%{
        var oFCKeditor = new FCKeditor('#{object.class.to_s.underscore}_#{attribute}', '730px', '350px') ;
        oFCKeditor.BasePath = "/fckeditor/" ;
				oFCKeditor.Config['ImageUploadURL'] = "/fckuploads?item_type=#{object.class}&id=#{object.new_record? ? current_user.login+'_'+current_user.id.to_s : object.id}&type=Image";
        oFCKeditor.ReplaceTextarea() ;

		})
  end

  # Footer of each item form. Status, comments, tags...
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end

	# Form part for the categories
  def item_category_fields(form, item)
    render :partial => "items/category", :locals => { :f => form, :item => item }
	end

	# Form part managing keywords
	def item_keywords_fields(form, item)
    render :partial => "items/keywords_fields", :locals => { :f => form, :item => item }
	end

	# Displays the tabs link to items
  def display_tabs(item_type)
    if current_workspace
			item_types = current_workspace.ws_items.split(',') & get_sa_config['sa_items']
			item_type ||= item_types.first.to_s.pluralize
    else
			item_types = get_sa_config['sa_items']
			item_type ||= item_types.first.to_s.pluralize
	  end
 
    content = String.new
    
		if item_type.nil?
			"(no items selected)"
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
        
        li_content += link_to_remote(image_tag(item_model.classify.constantize.icon_48),:method=>:get, :update => "content", :url => url)
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
      
			content_tag(:ul, content, :id => :tabs)
		end
	end

	# Displays the list of items
  def display_item_list(item_type, partial_used='items/item_in_list')
		# When the params[:item_type] is not define previously (by default for workspace)

		item_type ||= params[:item_type] ||= get_default_item_type
		if !item_type.blank?
#			items = item_type.classify.constantize.list_items_with_permission_for(@current_user, 'show', current_workspace)
#			@collection = items.paginate(:page => params[:page],:per_page=>PER_PAGE_VALUE)
#			if params[:filter_name]
#				params[:filter_way] ||= 'desc'
#				if params[:filter_way] == 'desc'
#					@collection = @collection.sort{ |x, y| y.send(params[:filter_name].to_sym) <=> x.send(params[:filter_name].to_sym) }
#				else
#					@collection = @collection.sort{ |x, y| x.send(params[:filter_name].to_sym) <=> y.send(params[:filter_name].to_sym) }
#				end
#			end
	    render(:partial => partial_used, :collection => @collection)
		else
			render :text => "()"
		end
  end

	def display_item_in_list_for_editor
		display_item_list(nil, 'items/item_in_list_for_editor')
	end

  def get_ajax_item_path(item_type)
    item_type =  params[:item_type].nil? ? get_default_item_type : params[:item_type]
    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    return url
  end
	
end