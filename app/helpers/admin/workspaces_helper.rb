module Admin::WorkspacesHelper

  # Create Link to Workspace
  def link_to_workspace(workspace)
    link_to(workspace.title, admin_workspace_url(workspace))
  end

  # Create Link to all worksapces
  def links_to_workspace_collection(workspaces)
    return nil if workspaces.empty?
    workspaces.collect { |ws| link_to_workspace(ws) }.join(', ')
  end

	# Helper method returning a field for user association (in Javascript)
  def new_user(object)
    javascript_tag js_add_new_user(object)
  end

  # Helper method creating a link calling a Javascript function adding a field for user association
  def link_to_new_user(name)
    link_to_function name, js_add_new_user(UsersWorkspace.new)
  end

  private
	# Helper method inserting the famous field for user association
  def js_add_new_user(object)
    update_page do |p|
      p.insert_html :bottom, 'newuser', :partial => 'user', :object => object
      p << "lastElement = $('newuser').childElements().last()"
      p << "textfield = lastElement.down('.text_field')"
      p << "autocomplete = lastElement.down('.autocomplete')"
      p << "new Ajax.Autocompleter(textfield, autocomplete, #{url_for(:controller => 'admin/users', :action => :index).inspect}, { method: 'get', paramName: 'login' })"
    end
  end   
end