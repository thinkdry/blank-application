module ArticlesHelper

	# Helper method returning a file field for file association (in Javascript)
  def new_file(object)
    javascript_tag js_add_new_file(object)
  end

  # Helper method creating a link calling a Javascript function adding a file field for file association
  def link_to_new_file(name)
    link_to_function name, js_add_new_file(ArticleFile.new)
  end
  
  private
	# Helper method inserting the famous file field for file association
  def js_add_new_file(object)
    update_page do |p|
      p.insert_html :bottom, 'files', :partial => 'file', :object => object
    end
  end  
  
end