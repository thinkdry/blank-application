module ItemsHelper
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
        :onclick      => "window.location.href = '#{item_url(object)}'"),
      block.binding
  end
  
  # Render a lisf of recent items, recent comments and recent publications.
  # (Uses the `small_item_list` helper)
  def item_list(conditions = {})
    conditions = { :workspace_id => current_user.workspaces } if conditions == {}
    
    list = Item.find(:all,
      :order => 'created_at DESC',
      :limit => 10,
      :conditions => conditions).collect { |item| item.itemable }
    render :partial => "items/list", :object => list
  end
  
  # Item. Type, title and author.
  # Modal window on mouseover, displaying additionnal informations
  def small_item_in_list(object)
    render :partial => "items/small_item_in_list", :object => object
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
  def item_tag name
    name
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_edit_item object
    link_to(
      image_tag('icons/pencil.png'),
      edit_item_url(object)
    ) if permit?("edit of object", :object => object)
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def link_to_remove_item object
    link_to(
      image_tag('icons/delete.png'),
      item_url(object),
      :confirm => 'Êtes vous sur de vouloir supprimer cet élément ? Cette action est irréversible.',
      :method => :delete
    ) if permit?("delete of object", :object => object)
  end

  # Resourceful helper. May be used in generic forms (acts_as_item).
  def item_url(object)
    self.send("#{object.class.to_s.underscore}_url", object.id)
  end
  
  # Resourceful helper. May be used in generic forms (acts_as_item).
  def edit_item_url(object)
    self.send("edit_#{object.class.to_s.underscore}_url", object.id)
  end
end