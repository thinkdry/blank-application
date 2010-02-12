module TagLib
  
  def page_title
    result ||= @site_page || @item || @current_website 
    return result.title
  end

  def path
    "/#{WEBSITE_FILES}/#{@current_website.title}"
  end

  def page_description
    result ||= @site_page || @item || @current_website
    return result.description
  end

  def page_keywords
    @site_page ? @site_page.keywords_list : ''
  end

  def site_title
    @current_website.title
  end
  
  def site_description
    @current_website.description
  end

  def powered_by
    str = 'Powered By'
    str += link_to 'ThinkDRY : Blank Application', 'http://www.blankapplication.org'
  end
end
