class WorkspaceContactsController < ApplicationController

	# Filter skipping the 'is_logged?' filter to allow non-logged user to unsubscribe from the newsletter
	skip_before_filter :is_logged?, :only => [:unsubscribe]
	before_filter :permission_checking, :except => [:unsubscribe, :subscribe_newsletter]

	def permission_checking
		no_permission_redirection unless @current_user && current_workspace && current_workspace.has_permission_for?('contacts_management', @current_user)
	end

	#To assing/remove workspace contacts URL: workspaces/1/add_contacts
  def select
    @current_object = current_workspace
    if request.get?
      @assigned_contacts = @current_object.people.all(:select =>"people.id, people.email")
      condition = @assigned_contacts.empty? ? "" : "people.id NOT IN (#{@assigned_contacts.map{|p| p.id}.join(',')}) AND "
      @available_contacts = Person.find_by_sql("SELECT people.id, people.email FROM people people WHERE #{condition}people.user_id = #{current_user.id} ORDER BY people.email ASC")
    else
      flash[:notice] = I18n.t('workspace.add_contacts.flash_notice')
      @current_object.selected_contacts = params[:selected_Options]
      redirect_to select_workspace_workspace_contacts_path(@current_object.id)
    end
  end

	def list
		if params[:contacts_workspaces_ids]
			if params[:to_do] == 'remove'
				params[:contacts_workspaces_ids].each do |e|
					cw=ContactsWorkspace.find(e)
					if cw.contactable_type == 'WebsiteContact'
						cw.contactable.destroy
					end
					cw.delete
				end
        flash[:notice] = I18n.t('workspace_contact.list.removed_contact_flash_notice')
			elsif params[:to_do] == 'link' && params[:group_id]
        group = Group.find(params[:group_id])
				params[:contacts_workspaces_ids].each do |e|
          if Grouping.find(:first, :conditions => {:group_id => params[:group_id].to_i, :contacts_workspace_id => e.to_i}).nil?
            a=Grouping.new(:group_id => params[:group_id].to_i, :contacts_workspace_id => e.to_i)
            a.save
          end
				end
        flash[:notice] = I18n.t('workspace_contact.list.linked_to_group_flash_notice', :name => group.title)
			elsif params[:to_do] == 'change_state'
				params[:contacts_workspaces_ids].map{ |e| ContactsWorkspace.find(e) }.each do |e|
					e.update_attributes(:state => params[:state])
				end
        flash[:notice] = I18n.t('workspace_contact.list.changed_state_flash_notice', :state => I18n.t('general.common_word.'+params[:state]).capitalize)
			end
		end
		params[:order] ||= 'created_at'
		params[:restriction] ||= 'all'
		if params[:restriction] == 'non_linked'
			group_ids = current_workspace.groups.map{ |e| e.id }
			current_objects = current_workspace.contacts_workspaces.delete_if do |cw|
				cw.groupings.delete_if{ |e| !group_ids.include?(e.group_id) }.first
			end
			@current_objects = current_objects.map{ |e| e.to_group_member(@current_user.id) }.sort{ |a,b| a[params[:order]] <=> b[params[:order]] }
		else
			@current_objects = current_workspace.contacts_workspaces.map{ |e| e.to_group_member(@current_user.id) }.sort{ |a,b| a[params[:order]] <=> b[params[:order]] }
		end
	end

	def subscribe
		if params[:remove]
			a=ContactsWorkspace.find(:first, :conditions => {
					:workspace_id => params[:workspace_id],
					:contactable_id => @current_user.id,
					:contactable_type => @current_user.class.to_s,
					:state => nil
				}
			)
			if a.destroy
				flash[:notice] = I18n.t('group.subscribe.unsubscribe_flash_notice')
				redirect_to workspace_path(params[:workspace_id])
			else
				flash[:error] = I18n.t('group.subscribe.unsubscribe_flash_error')
				redirect_to workspace_path(params[:workspace_id])
			end
		else
			if ContactsWorkspace.create(
				:workspace_id => params[:workspace_id],
				:contactable_id => @current_user.id,
				:contactable_type => @current_user.class.to_s,
				:state => nil
			)
				flash[:notice] = I18n.t('group.subscribe.subscribe_flash_notice')
				redirect_to workspace_path(params[:workspace_id])
			else
				flash[:error] = I18n.t('group.subscribe.subscribe_flash_error')
				redirect_to workspace_path(params[:workspace_id])
			end
		end
	end

	# Method to unsubscribe from a newsletter for given sha1_id
  #
	# TODO bl i
	#
  # Usage URL:
  #
  # /unsubscribe_for_newsletter?cid=#{sha1_id of contacts_workspace}
  #
  def unsubscribe
    contact_workspace = ContactsWorkspace.find(:first, :conditions => ["sha1_id = '#{params[:cid]}'"])
    if contact_workspace && contact_workspace.update_attribute(:state, 'unsubscribed')
      flash[:notice] = I18n.t('newsletter.unsubscribe.flash_notice')
    else
      flash[:error] = "Unable to unsubscribe. Please try again."
    end
    redirect_to "/"
  end

end