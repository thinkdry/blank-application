# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	include AjaxPagination

	# List f the different keys used for flash messages
  FLASH_NOTICE_KEYS = [:error, :notice, :warning]

  # Select Language
  #
  # This method is creating a select box displaying all the languages activated from the SuperAdministration
	# configuration. After a selection of a language, an Ajax request is made calling the 'change_language' method
	# defined in the Session controller
	# If there is just one language available, it is returning an empty string.
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
	# This method is used to generate checkboxes from a list of strings.
	#
	# Parameters :
	# - var: List of strings that will define the value to check
	# - param: String that will define the parameter that will send the checked values
	# - conf: Hash giving the actual value for the list
	# - object: String that will define also the parameter that will send the checked value (like that : object[param][] )
  #
  # Usage:
  # <tt>checkboxes_from_list(ITEMS, sa_items, @conf, "conf") </tt>
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
  # This method will return a select box with the different models available for the Search part.
	def select_search_models
		res = "<select name='search[category]' id='search_category' onchange=\"if ($('advanced_search').visible()) new Ajax.Updater('advanced_search', '/searches/print_advanced?search[category]='+$('search_category').value);\">"
		#res += "<option value='all'>"+I18n.t('general.common_word.all').upcase+"</option>"
		#res += "<option value=''>----------</option>"
		res += "<option value='item'#{(@search.category == 'item') ? ' selected=selected' : ''}'>"+I18n.t('general.object.item').pluralize.upcase+"</option>"
		item_types_allowed_to(@current_user, 'show', current_workspace).each do |i|
			res += "<option value='#{i}'#{(@search.category == i) ? ' selected=selected' : ''}'>"+I18n.t('general.item.'+i).pluralize+"</option>"
		end
		#res += "<option value=''>----------</option>"
		#res += "<option value='workspace'>"+I18n.t('general.object.workspace').pluralize.upcase+"</option>"
		#res += "<option value=''>----------</option>"
		#res += "<option value='user'>"+I18n.t('general.object.user').pluralize.upcase+"</option>"
		res += "</select>"
		return res
	end

	# Distance between two time
	#
	# This method will calculate the distance between two times
	# and generate a humanized String answer.
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
			else
				I18n.l from_time, :format => :long1
			end
		end
  end

  # Workspaces checkboxes 
  #
  # Usage:
  #
  # <tt>item_status_fields(form, article)</tt>
  #
  # will return all the checkboxes linked to workspaces for that item, with the different options set (disabled, checked or hidden)
	def associated_workspaces_checkboxes(form, object, permission = nil)
		strg = ""
		object_class_name = object.class.to_s.underscore
		check_box_tag_name = "associated_workspaces[]"
		res=[]
    permission = permission || object_class_name+"_new"
		# Workspace list allowing user to add new item and accepting items of that type
		list = (res + Workspace.allowed_user_with_permission(@current_user.id, permission)).uniq
		#
		if (list.size > 1 || @current_user.has_system_role('superadmin'))
			strg += "<label>#{I18n.t('general.object.workspace').camelize+'(s) :'}</label><div class='formElement'>"
			#form.field(:workspaces, :label => I18n.t('general.object.workspace').camelize+'(s) :', :ajax => false)
			list.collect do |w|
				# Setting the checked status form that workspace
				if params[:associated_workspaces]
          checked = params[:associated_workspaces].include?(w.id.to_s)
				else
          checked = ContactsWorkspace.exists?(:workspace_id => w.id, :contactable_id => object.id, :contactable_type => object.class.to_s) if object
				end
				# Creating the checkboxes
				if ((w.state == 'private') && (w.creator_id == @current_user.id) && object && (object.new_record? || object.user_id==@current_user.id)) || (list.size==1) || (w == current_workspace)
					strg += check_box_tag(check_box_tag_name, w.id, true, :disabled => true, :class => 'checkboxes') + ' ' + w.title + hidden_field_tag(check_box_tag_name, w.id.to_s) + '<br />'
				else
					strg += check_box_tag(check_box_tag_name, w.id, checked, :class => 'checkboxes') + ' ' + w.title + '<br />'
				end
			end
			strg += '</div>'
		elsif (list.size > 0)
			list.each do |ws|
				strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
			end
		end
    if object && object.workspaces
      (object.workspaces - list).each do |ws|
        strg += hidden_field_tag(check_box_tag_name, ws.id.to_s)
      end
    end
		return strg
	end
end
