module ArticlesHelper
	
  def new_file(object)
    javascript_tag js_add_new_file(object)
  end
  
  def link_to_new_file(name)
    link_to_function name, js_add_new_file(ArticleFile.new)
  end
  
  private
  def js_add_new_file(object)
    update_page do |p|
      p.insert_html :bottom, 'files', :partial => 'file', :object => object
    end
  end  
  
  # override of acts_as_item helper.
  # used in popup of fckeditor to display the item : 
  # Link on title, for article, link on image for image etc.
  def item_display_for_pop_up(url, object)
    link_to_function object.title, "javascript:SelectFile('" + url + "')"
  end
	
end

#    if object.class == 'Image'
#      obj= Image.find_by_id(object.id)
#      url = '/uploaded_files/image/'+obj.id.to_s+'/original/'+obj.image_file_name
#      link_to_function obj.title, "javascript:SelectFile('" + url + "')"
#    else