module PeopleHelper

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