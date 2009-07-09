module AjaxPagination

  # TODO enhance, test and include in library

  # Ajax Pagination For Content Page
  #
  # Usage:Called from the View as
  #
  # <tt>remote_pagination(@paginated_objects, ajax_url,  'object-list')</tt>
  #
  # will refresh the div with new paginated_objects
  #
  # Parameters
  #
  # - collection: Collection of Item
  # - url: '/people/ajax_index/?page=' last parameter in the url should be 'page='
  # - refeshed_div: 'object-list'
  def remote_pagination(collection, url, refreshed_div)
		#url = request.url.split('?').first
		url = url.split('?').first
		paramss = ((tmp=request.url.split('?')).size > 1) ? tmp.last : '' # why use request.url and not url in param
		paramss = (!paramss.blank?) ? paramss.split('&page=').first+'&page=' : 'page='
    url = url+'?'+paramss
    if !collection.nil? and collection.total_pages > 1
    content = String.new
#		item_type =  params[:item_type].nil? ? get_default_item_type(current_workspace) : params[:item_type]
#    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    current_page = params[:page] ? params[:page].to_i : 1
    if current_page == 1
      content = "&laquo; #{I18n.t('general.common_word.prev')} "
    else
     content = content + link_to_remote("&laquo; #{I18n.t('general.common_word.prev')} ", :update => refreshed_div,:method=>:get, :url =>url+"#{current_page - 1}")
    end
    prev = nil
    visible_page_numbers(current_page,collection.total_pages).each do |page_no|
        content = content+((prev and page_no > prev + 1) ? "&hellip;" : " ")
        prev = page_no
        if current_page == page_no
          content = content+content_tag(:b,page_no.to_s)
        else
          content = content+ link_to_remote(page_no.to_s, :update => refreshed_div,:method=>:get, :url =>url+"#{page_no}")
        end
    end
    if current_page == collection.total_pages
      content = content +"  #{I18n.t('general.common_word.next')} &raquo;"
    else
      content = content + link_to_remote("  #{I18n.t('general.common_word.next')} &raquo;", :update => refreshed_div,:method=>:get, :url =>url+"#{(current_page+1)}")
    end
    return content_tag(:div, content_tag(:div, content, :align=>"center"), :id => "pagination")
    end
  end

  # Page Numbers that should be Visible for Pagination
  #
  # Usage:
  #
  # <tt>visible_page_numbers(5,20)</tt>
  #
  # will return array of visible numbers
  #
  # Parameters:
  #
  # - current_page: current_page_number
  # - total_pages: total_pages
  def visible_page_numbers(current_page,total_pages)
      inner_window, outer_window = 4, 1
      window_from = current_page - inner_window
      window_to = current_page + inner_window

      # adjust lower or upper limit if other is out of bounds
      if window_to > total_pages
        window_from -= window_to - total_pages
        window_to = total_pages
      end
      if window_from < 1
        window_to += 1 - window_from
        window_from = 1
        window_to = total_pages if window_to > total_pages
      end

      visible   = (1..total_pages).to_a
      left_gap  = (2 + outer_window)...window_from
      right_gap = (window_to + 1)...(total_pages - outer_window)
      visible  -= left_gap.to_a  if left_gap.last - left_gap.first > 1
      visible  -= right_gap.to_a if right_gap.last - right_gap.first > 1

      visible
  end

end