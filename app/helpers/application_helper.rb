# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]
	def small_item_in_list(item)
		# display all items by category
		# ...	
		content_tag :h2, item.title
		content_tag :p, item.description		
	end
        
  def flash_messages
		return unless messages = flash.keys.select{|k| FLASH_NOTICE_KEYS.include?(k)}
			formatted_messages = messages.map do |type|      
			content_tag :div, :class => type.to_s do
				message_for_item(flash[type], flash["#{type}_item".to_sym])
			end
    end
    formatted_messages.join
  end

  def message_for_item(message, item = nil)
    if item.is_a?(Array)
      message % link_to(*item)
    else
      message % item
    end
  end
  
  def display_top_items_tabs(page)
    html = '<ul id="tabs" class="without_img">'
    html += '<li '
    html += 'class="selected"' if (page=="comment")
    html += '>'+link_to("Les + commentés", "#")+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="note")
    html += '>'+link_to("Les mieux notés", "#")+'</li>'
    html += '<li '
    html += 'class="selected"' if (page=="view")
    html += '>'+link_to("Les + lus", "#")+'</li>'
    html += '</ul><div class="clear"></div>'
	end

	def select_languages
		if (available_languages.size > 1)
			res = "<select name='languages' id='languages' onchange=\"new Ajax.Request('/session/change_language?locale='+this.value, {asynchronous:true, evalScripts:true}); return false;\">"
			available_languages.each do |l|
        if I18n.locale==l
          res += "<option value='#{l}' selected=true>"+I18n.t('general.language.'+l)+"</option>"
        else
          res += "<option value='#{l}'>"+I18n.t('general.language.'+l)+"</option>"
        end
				
			end
			res += "</select>"
		else
			res = ""
		end
		return res
	end

	def checkboxes_from_list(var, param, conf, object)
		res = []
		var.each do |l|
			res << check_box_tag(object+'['+param+']'+"[]", "#{l}", ((ref=conf[param]) ? ref.include?(l) : false))+' '+I18n.t('general.item.'+l)
    end
		return res.join(' | ')
	end

	def select_search_models
		res = "<select name='search[category]' id='search_category' onchange=\"if ($('advanced_search').visible()) new Ajax.Updater('advanced_search', '/searches/print_advanced?search[category]='+$('search_category').value);\">"
		#res += "<option value='all'>"+I18n.t('general.common_word.all').upcase+"</option>"
		#res += "<option value=''>----------</option>"
		res += "<option value='item'>"+I18n.t('general.object.item').pluralize.upcase+"</option>"
		available_items_list.each do |i|
			res += "<option value='#{i}'>"+I18n.t('general.item.'+i).pluralize+"</option>"
		end
		#res += "<option value=''>----------</option>"
		#res += "<option value='workspace'>"+I18n.t('general.object.workspace').pluralize.upcase+"</option>"
		#res += "<option value=''>----------</option>"
		#res += "<option value='user'>"+I18n.t('general.object.user').pluralize.upcase+"</option>"
		res += "</select>"
		return res
	end

  ###############################

	# TODO enhance, test and include in library
  # Needs two arguments one is collection objec and another is url. url should look like '/people/ajax_index/?page=' last parameter in the url should be 'page='
  def remote_pagination(collection,url)
    if !collection.nil? and collection.total_pages > 1
    content = String.new
#		item_type =  params[:item_type].nil? ? get_default_item_type : params[:item_type]
#    url = current_workspace ? ajax_items_path(item_type) +"&page=" : ajax_items_path(item_type) +"?page="
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
  end

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
