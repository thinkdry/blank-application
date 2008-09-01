module ItemsHelper
  def item_show(parameters, &block)
    concat\
      render( :partial => "items/show",
              :locals => {  :object => parameters[:object],
                            :title => parameters[:title],
                            :block => block                 } ),
      block.binding
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
        :onclick      => "window.location.href = '#{item_url(object)}'"),
      block.binding
  end
  
  # Render a lisf of recent items, recent comments and recent publications.
  # (Uses the `small_item_list` helper)
  def item_list(params = Hash.new)
    
    # Default params
    params[:workspaces] = Array(params[:workspaces]) || current_user.all_workspaces
    params[:include_private_items] ||= params[:workspaces].empty? ? true : false
    
    items = [] # List being rendered
    
    # 1st: Collect items in workspaces
    unless params[:workspaces].empty?
      conditions = [ "workspace_id IN (?)", params[:workspaces] ]
      items = Item.find(:all,
        :order => 'created_at DESC',
        :limit => 10,
        :conditions => conditions)
      items.collect! { |item| item.itemable }
    end
    
    # 2nd: Include private item
    if params[:include_private_items]
      [:images, :articles, :audios, :artic_files, :videos].each do |itemable_type|
        items |= current_user.send(itemable_type)
      end
    end
    
    # Sort by CREATED_AT DESC
    items.sort! {|a, b| b.created_at <=> a.created_at }
    
    render :partial => "items/list", :object => items[0..10]
    
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
  
  def method_missing(method, object)
    begin
      prefix_length = method.to_s =~ /_?((item_url)|(item_path))$/
      raise unless prefix_length

      method_name = object.class.to_s.underscore + '_url'
      method_name.insert(0, method.to_s[0..prefix_length - 1] + '_') if prefix_length > 0
      send(method_name, object)
    rescue Exception => e
      raise NoMethodError, "NoMethodError : `#{method}`"
    end
  end
end