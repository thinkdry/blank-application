module WorkspacesHelper  
  def new_user(object)
    javascript_tag js_add_new_user(object)
  end
  
  def link_to_new_user(name)
    link_to_function name, js_add_new_user(UsersWorkspace.new)
  end
  
  private
  def js_add_new_user(object)
    update_page do |p|
      p.insert_html :bottom, 'users', :partial => 'user', :object => object
      p << "lastElement = $('users').childElements().last()"
      p << "textfield = lastElement.down('.text_field')"
      p << "autocomplete = lastElement.down('.autocomplete')"
      p << "new Ajax.Autocompleter(textfield, autocomplete, #{url_for(:controller => :users, :action => :index).inspect}, { method: 'get', paramName: 'login' })"
    end
  end   
end