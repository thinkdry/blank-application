module WorkspacesHelper
  def link_to_workspace(workspace)
    link_to(workspace.name, workspace_url(workspace))
  end
  
  def links_to_workspace_collection(workspaces)
    return nil if workspaces.empty?
    workspaces.collect { |ws| link_to_workspace(ws) }.join(', ')
  end
  
  def new_user(object)
    javascript_tag js_add_new_user(object)
  end
  
  def link_to_new_user(name)
    link_to_function name, js_add_new_user(UsersWorkspace.new)
  end
  
  def user_list_of(workspace, role)
    workspace.send(role).map { |u| link_to_user(u) }.join(', ')
  end
  
  private
  def js_add_new_user(object)
    update_page do |p|
      p.insert_html :bottom, 'newuser', :partial => 'user', :object => object
      p << "lastElement = $('newuser').childElements().last()"
      p << "textfield = lastElement.down('.text_field')"
      p << "autocomplete = lastElement.down('.autocomplete')"
      p << "new Ajax.Autocompleter(textfield, autocomplete, #{url_for(:controller => :users, :action => :index).inspect}, { method: 'get', paramName: 'login' })"
    end
  end   
end