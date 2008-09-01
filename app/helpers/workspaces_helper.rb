module WorkspacesHelper
  def current_workspace
    return @workspace if @workspace
    return @current_object if @current_object && @current_object.class == Workspace
    if params['workspace_id']
      @workspace = Workspace.find(params['workspace_id'].to_i)
      return @workspace
    end
    nil
  end
  
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