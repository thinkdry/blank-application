module ItemsHelper
  def item_in_list(object, thumb = nil)
    render :partial => "items/item_in_list", :object => object
  end
  
  def item_status_fields(form, item)
    render :partial => "items/status", :locals => { :f => form, :item => item }
  end
  
  def item_tag name
    name
  end
  
  def link_to_edit_item object
    link_to(
      image_tag('icons/pencil.png'),
      edit_item_url(object)
    ) if permit?("edit of object", :object => object)
  end
  
  def link_to_remove_item object
    link_to(
      image_tag('icons/delete.png'),
      item_url(object),
      :confirm => 'Êtes vous sur de vouloir supprimer cet élément ? Cette action est irréversible.',
      :method => :delete
    ) if permit?("delete of object", :object => object)
  end

  def item_url(object)
    self.send("#{object.class.to_s.underscore}_url", object.id)
  end
  
  def edit_item_url(object)
    self.send("edit_#{object.class.to_s.underscore}_url", object.id)
  end
    
end