module ContainersHelper

  # Create Link to Workspace
  def link_to_workspace(workspace)
    link_to(workspace.title, workspace_url(workspace))
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
  def form_for_container(object, title = '', &block)
		concat(render(:partial => "containers/form", :locals => { :block => block, :title => title }))
  end



	# Define the common information of the show of an item
	def container_show(parameters, &block)
    concat(
      render( :partial => "containers/show",
        :locals => {  :object => parameters[:object],
          :title => parameters[:title],
          :block => block }))
  end

  private
  # Helper method inserting the famous field for user association
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