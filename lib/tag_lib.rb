module TagLib
  include CustomTags

	def current_page
		params[:title_sanitized] ? params[:title_sanitized] : nil
	end

  def page_body
    liquidize_page_body(render :partial => 'websites/page')
  end
  
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

  ITEMS.each do |item|
      define_method item.pluralize.to_sym do |*args|
        options = args.extract_options!
        items = item.classify.constantize.get_da_objects_list(setting_searching_params(:from_params => build_params(options.merge!(:items => [item]))))
        str = ""
        items.each do |item|
          str += "<li>" + (link_to item.title, "/#{item}/#{item.title_sanitized}") + "</li>"
        end
        return str
      end
    end

  def items(*args)
    options = args.extract_options!
    options[:items] ||= @current_website.available_items.split(',')
    search = Search.new(setting_searching_params(:from_params => build_params(options)))
    items = search.do_search
    str = ""
    items.each do |item|
      str += "<li>" + (link_to item.title, "/#{item.class.to_s.underscore}/#{item.title_sanitized}") + "</li>"
    end
    return str
  end

  protected

  def build_params(options)
    options[:field] ||= 'created_at'
    options[:order] ||= 'desc'
    options[:limit] ||= 5
    {
      :m => options[:items],
      :by => "#{options[:field]}-#{options[:order]}",
      :per_page => options[:limit],
      :containers => {:website => ['1']}
    }
  end


end
