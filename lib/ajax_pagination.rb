# This module is defining helper methods to manage AJAX pagination.
#
# It is requiring the WillPaginate plugin.
#
module AjaxPagination

  # Ajax Pagination for objects list
  #
	# This helper method will manage all the pagination in the view,
	# refreshing the div with the new values (from the collection) given from the url.
	#
	# Parameters :
  # - collection: Collection of items (Array)
  # - url: String defining the URL to call for the AJAX request (the last parameter in the url should be 'page=')
  # - refeshed_div: String defining the name of the div to refresh
	#
  # Usage in a view :
  # - <tt>remote_pagination(@paginated_objects, ajax_url,  'object-list')</tt>
  def remote_pagination(collection, url, refreshed_div)
		url = url.split('?').first
		paramss = ((tmp=request.url.split('?')).size > 1) ? tmp.last : '' # why use request.url and not url in param
    paramss = paramss.split('&').delete_if{|p| p.include?('page')}.join('&') # to remove previous page param
		paramss = (!paramss.blank?) ? paramss.split('&page=').first+'&page=' : 'page='
    url = url+'?'+paramss
    if !collection.nil? and collection.total_pages > 1
      content = String.new
    
      current_page = params[:page] ? params[:page].to_i : 1
      
      #display previews page Link
      if current_page == 1
        content = "<span class=\"paginationBorderUnactive\">#{I18n.t('general.common_word.prev')}</span> "
      else
        content = content + link_to_remote("#{I18n.t("general.common_word.prev")} ", 
                                           :method => :get, 
                                           :url => url+"#{current_page - 1}",
                                           :html => {:class => 'paginationBorderActive'})
      end
      
      #display pages links
      prev = nil
      visible_page_numbers(current_page,collection.total_pages).each do |page_no|
          content = content+((prev and page_no > prev + 1) ? "&hellip;" : " ")
          prev = page_no
          #Current Page
          if current_page == page_no
            content = content + link_to_remote( page_no.to_s, 
                                                :method => :get, 
                                                :url => url+"#{page_no}", 
                                                :html => {:class => 'paginationSelected'})
          #Another page, not current
          else
            content = content + link_to_remote(page_no.to_s, 
                                               :method => :get, 
                                               :url =>url+"#{page_no}", 
                                               :html => {:class => 'paginationUnselected'})
          end
      end
      
      #display next page Link
      if current_page == collection.total_pages
        content = content + " <span class=\"paginationBorderUnactive\">#{I18n.t('general.common_word.next')}</span>"
      else
        content = content + link_to_remote( " #{I18n.t("general.common_word.next")}",
                                            :method => :get,
                                            :url => url+"#{(current_page+1)}",
                                            :html => {:class => "paginationBorderActive"})
      end
      
      #return total pagination in pagination id div.
      return content_tag(:div, content, :id => "pagination")
    end
  end

  # Pages number visible for pagination
  #
	# This helper method will generate the links allowing to navigate through the pages
	# generated with the pagination.
	#
	# Parameters :
  # - current_page: Integer defining the current page number
  # - total_pages: Integer defining the total pages number for the collection
	#
  # Usage :
  # - <tt>visible_page_numbers(5,20)</tt>
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