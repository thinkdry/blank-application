module SearchesHelper
	
	# Select Box for Search
  #
  # This method will return a select box with the different models available for the Search part.
	def select_search_models
		res = "<select name='cat' id='search_category' onchange=\"if ($('advanced_search').visible()) new Ajax.Updater('advanced_search', '/searches/print_advanced?cat='+$('search_category').value);\">"
		#res += "<option value='all'>"+I18n.t('general.common_word.all').upcase+"</option>"
		#res += "<option value=''>----------</option>"
		res += "<option value='item'#{(@search.category == 'item') ? ' selected=selected' : ''}'>"+I18n.t('general.object.item').pluralize.upcase+"</option>"
		item_types_allowed_to(@current_user, 'show', current_workspace).each do |i|
			res += "<option value='#{i}'#{(@search.category == i) ? ' selected=selected' : ''}'>"+I18n.t('general.item.'+i).pluralize+"</option>"
		end
		res += "<option value=''>----------</option>"
		res += "<option value='workspace'>"+I18n.t('general.object.workspace').pluralize.upcase+"</option>"
		res += "<option value=''>----------</option>"
		res += "<option value='user'>"+I18n.t('general.object.user').pluralize.upcase+"</option>"
		res += "</select>"
		return res
	end

  # Output Format for Search Results 
  def page_entries_info(collection, options = {})
  entry_name = I18n.t('layout.search.result')
  if collection.total_pages < 2
    case collection.size
    when 0; I18n.t('general.common_word.no1').capitalize+" #{entry_name}"
    when 1; "<b>1</b> #{entry_name}"
    else;   I18n.t('layout.search.displaying').capitalize+" <b>#{collection.size}</b> #{entry_name.pluralize}"
    end
  else
    %{#{I18n.t('layout.search.displaying').capitalize} #{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> #{I18n.t('general.common_word.of')} <b>%d</b> #{I18n.t('general.common_word.found')}} % [
      collection.offset + 1,
      collection.offset + collection.length,
      collection.total_entries
    ]
  end
end
end