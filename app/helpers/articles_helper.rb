module ArticlesHelper
	
  def new_file(object)
    javascript_tag js_add_new_file(object)
  end
  
  def link_to_new_file(name)
    link_to_function name, js_add_new_file(ArticlesArticFile.new)
  end
  
  private
  def js_add_new_file(object)
    update_page do |p|
      p.insert_html :bottom, 'files', :partial => 'file', :object => object
    end
  end   
	
end