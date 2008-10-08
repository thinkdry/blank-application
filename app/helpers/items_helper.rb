module ItemsHelper
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
  
  def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
  end
  
  def advanced_editor_on(object, attribute)
    javascript_tag(%{
			bkLib.onDomLoaded(function() {
				new nicEditor({iconsPath : '/images/nicEditorIcons.gif'}).panelInstance('#{object.class.to_s.underscore}_#{attribute}');
			});
		})
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
  
  def form_for_item(object, title = '', &block)
    concat(render(:partial => "items/form", :locals => { :block => block, :title => title }), block.binding)
  end
  
  # Render a lisf of recent items, recent comments and recent publications.
  # (Uses the `small_item_list` helper)
  def item_list
    items = [] # List being rendered
    
    # 1st: Collect items in workspaces
    conditions = [ "workspace_id IN (?)", current_workspace || current_user.all_workspaces ]
    items = Item.find(:all,
      :order => 'created_at DESC',
      :limit => 10,
      :conditions => conditions)
    items.collect! { |item| item.itemable }
    
    # 2nd: Include private item
    unless current_workspace
      [:images, :articles, :audios, :artic_files, :videos].each do |itemable_type|
        items |= current_user.send(itemable_type)
      end
    end
    
    # Sort by CREATED_AT DESC
    items.sort! {|a, b| b.created_at <=> a.created_at }
    
    render :partial => "items/list", :object => items[0..10]
  end
  
  # Item. Title and descriptions.
  # Modal window on mouseover, displaying additionnal informations
  def item_in_list(object, thumb = nil)
    render :partial => "items/item_in_list", :object => object
  end
  
  # Footer of each item form. Status, comments, tags...
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end
  
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
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_edit_item object
    link_to(
      image_tag('icons/pencil.png'),
      item_path(object)
    )
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_remove_item object
    link_to(
      image_tag('icons/delete.png'),
      item_path(object),
      :confirm => 'Êtes vous sur de vouloir supprimer cet élément ? Cette action est irréversible.',
      :method => :delete
    )
  end
  
  def link_to_item(object)
    link_to(object.title, item_path(object))
  end
  
  def display_tabs(page)
    content = String.new
    
    [Article, Image, ArticFile, Video, Audio, Publication].each do |item_model|
      item_page = item_model.to_s.underscore.pluralize
      item_human_name = item_page
      options = {}
      options[:selected] = true if (page == item_page)

      content += content_tag(
        :li,
        link_to(image_tag(item_model.icon) + item_human_name, items_path(item_model)),
        options
      )
    end
    
    content_tag(:ul, content, :id => :tabs)
	end
  
  def display_item_list(page)
    items = if current_workspace
      GenericItem.from_workspace(current_workspace)
    else
      GenericItem.consultable_by(@current_user)
    end
    
    collection = items.send(page, :order => 'created_at DESC')
    
    render(:partial => "items/item_in_list", :collection => collection.to_a)
  end
  
end