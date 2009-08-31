module GenericForItemsHelper

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_list(items_list, ajax_url)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  # - ajax_url: ajax item path for the item_type
	def display_items_list(items_list, ajax_url, partial_used='generic_for_items/items_list')
	  content = render :partial => partial_used, :locals => { :ajax_url => ajax_url }
		return content_tag(:div, content, :id => "object-list")
	end

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_in_list(items_list)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  def display_item_in_list(items_list, partial_used='generic_for_items/item_in_list')
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Display Item in List for Editor
	def display_item_in_list_for_editor
		display_item_list('generic_for_items/item_in_list_for_editor')
	end

  # Classify Bar for Ordering, Filtering Items
  #
  # Usage:
  #
  # <tt>display_classify_bar(['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'], ajax_url, 'object-list')</tt>
  #
  # will return classify bar for item list with option to filter on fields
  #
  # Parameters:
  #
  # - ordering_fields_list: 'created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'
  # - ajax_url: url to be passed to be called on click of item
  # - refreshed_dv: objects-list
  # - partial_used : 'items/classify_bar'
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='generic_for_items/classify_bar')
		render :partial => partial_used, :locals => {
      :ordering_fields_list => ordering_fields_list,
      :ajax_url => ajax_url,
      :refreshed_div => refreshed_div
		}
	end

  # Ajax Item Path
  #
  # Usage:
  #
  # <tt>get_ajax_item_path('article')</tt>
  #
  # Will return the ajax_items_path depending on the current_worksapces
  def get_ajax_item_path(item_type)
    item_type ||=  get_allowed_item_types(current_workspace).first.pluralize
    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
    current_page = params[:page] ? params[:page].to_i : 1
    if current_page == 1
      content = "&laquo; Previous "
    else
     content = content + link_to_remote("&laquo; Previous  ", :update => "content",:method=>:get, :url =>url+"#{current_page - 1}")
    end
    prev = nil
    visible_page_numbers(current_page,collection.total_pages).each do |page_no|
        content = content+((prev and page_no > prev + 1) ? "&hellip;" : " ")
        prev = page_no
        if current_page == page_no
          content = content+content_tag(:b,page_no.to_s)
        else
          content = content+ link_to_remote(page_no.to_s, :update => "content",:method=>:get, :url =>url+"#{page_no}")
        end
    end
    if current_page == collection.total_pages
      content = content +"  Next &raquo;"
    else
      content = content + link_to_remote("  Next &raquo;", :update => "content",:method=>:get, :url =>url+"#{(current_page+1)}")
    end
    return content_tag(:div, content, :align=>"center")
  end

	# Safe Url for Classify Bar
	def safe_url(url, params)
		# TODO generic allowing to replace params in url
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
		return (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')

#    return url+'/?'+params.join('&')
	end

  # Render Specific Partial according to Item Type passed
  #
  # Usage get_specific_partial('article', preview, article_object)
  #
  # will render the partial depending on the item_type
  def get_specific_partial(item_type, partial, object)
    if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
      render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
    else
      render :nothing => true
    end
  end

  def display_generic_items_tab(partial_name= 'top_box')
    if current_workspace
        most_commented = GenericItem.from_workspace(current_workspace.id).most_commented.to_a
        best_rated = GenericItem.from_workspace(current_workspace.id).best_rated.to_a
        feed_items = FeedItem.from_workspace(current_workspace.id).latest.to_a
    else
        most_commented = GenericItem.consultable_by(current_user.id).most_commented.to_a
        best_rated = GenericItem.consultable_by(current_user.id).best_rated.to_a
        feed_items = FeedItem.consultable_by(current_user.id).latest.to_a
    end
    return render :partial => "generic_for_items/"+partial_name,
                :locals =>{:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items}
  end

end