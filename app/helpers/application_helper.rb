# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include AjaxPagination
	
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]

  # Select Language
  #
  # Create Select Box for all the Languages Available in SuperAdministration Configuration
  #
  # On Selection of Language Ajax Request is Made to 'change_language'
  #
  # will change the local language to selected option
  #
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

  # Checkboxes from list
  #
  #
  # Usage:
  #
  # <tt>checkboxes_from_list(ITEMS, sa_items, @conf, "conf") </tt>
  #
  # will return group of checkboxes with passed ITEMS
	def checkboxes_from_list(var, param, conf, object)
		res = []
		var.each do |l|  
      content = '<div class="checkbox_list_horizontal">'
      content += check_box_tag(object+'['+param+']'+"[]", "#{l}", ((ref=conf[param]) ? ref.include?(l) : false), :class => "checkboxes")+' '+I18n.t('general.item.'+l)
      content += "</div>"
    
			res << content 
    end
		return res
	end

  # Select Box for Search
  #
  # will return select box for all available items
	def select_search_models
		res = "<select name='search[category]' id='search_category' onchange=\"if ($('advanced_search').visible()) new Ajax.Updater('advanced_search', '/searches/print_advanced?search[category]='+$('search_category').value);\">"
		#res += "<option value='all'>"+I18n.t('general.common_word.all').upcase+"</option>"
		#res += "<option value=''>----------</option>"
		res += "<option value='item'#{(@search.category == 'item') ? ' selected=selected' : ''}'>"+I18n.t('general.object.item').pluralize.upcase+"</option>"
		available_items_list.each do |i|
			res += "<option value='#{i}'#{(@search.category == i) ? ' selected=selected' : ''}'>"+I18n.t('general.item.'+i).pluralize+"</option>"
		end
		#res += "<option value=''>----------</option>"
		#res += "<option value='workspace'>"+I18n.t('general.object.workspace').pluralize.upcase+"</option>"
		#res += "<option value=''>----------</option>"
		#res += "<option value='user'>"+I18n.t('general.object.user').pluralize.upcase+"</option>"
		res += "</select>"
		return res
	end

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false,options = {})
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    I18n.with_options :locale => options[:locale], :scope => 'datetime.distance_in_words' do |locale|
    case distance_in_minutes
    when 0..1           then (distance_in_minutes==0) ? (locale.t :less_than_a_minute, :count => 5) : (locale.t :one_minute_ago, :count => distance_in_minutes)
    when 2..59          then locale.t :x_minutes_ago, :count => distance_in_minutes 
    when 60..90         then locale.t :one_hour_ago, :count => distance_in_minutes
    when 90..1440       then locale.t :x_hours_ago, :count => (distance_in_minutes.to_f / 60.0).round
    when 1440..2160     then locale.t :one_day_ago, :count => distance_in_minutes # 1 day to 1.5 days
    when 2160..2880     then locale.t :x_days_ago, :count => (distance_in_minutes.to_f / 1440.0).round # 1.5 days to 2 days
    else I18n.l from_time, :format => :long1
    end
  end
  end
end
