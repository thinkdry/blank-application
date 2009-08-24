# This controller is managing the different actions relative to the Group item.
#
# It is using a mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# so see the documentation of that module for further informations.
#

class GroupsController < ApplicationController

	acts_as_ajax_validation

	before_filter :permission_checking, :except => [:unsubscribe]

	def permission_checking
		no_permission_redirection unless current_user && @current_user.has_workspace_permission(current_workspace.id, 'workspace', 'contacts_management')
	end

	# Filter skipping the 'is_logged?' filter to allow non-logged user to unsubscribe from the newsletter
	skip_before_filter :is_logged?, :only => [:unsubscribe]

	def index
		@current_objects = current_workspace.groups
	end

	def new
		@current_object = Group.new
		@current_object.workspace_id = params[:workspace_id]
		get_contacts_lists
	end

	def edit
		@current_object = Group.find(params[:id])
		get_contacts_lists
	end

	def create
		@current_object = Group.new(params[:group])
		@current_object.user_id = @current_user.id
		@current_object.workspace_id = params[:workspace_id]
		@current_object.groupable_objects = params[:selected_Options]
		if @current_object.save
			flash[:notice] = I18n.t('item.new.flash_notice')
			redirect_to workspace_group_path(params[:workspace_id], @current_object)
		else
			get_contacts_lists
			flash[:error] = I18n.t('item.new.flash_error')
			render :action => :new
		end
	end

	def update
		@current_object = Group.find(params[:id])
		@current_object.groupable_objects = params[:selected_Options]
		if @current_object.update_attributes(params[:current_object])
			flash[:notice] = I18n.t('item.edit.flash_notice')
			redirect_to workspace_group_path(params[:workspace_id], @current_object)
		else
			get_contacts_lists
			flash[:error] = I18n.t('item.edit.flash_error')
			render :action => :edit
		end
	end

	def show
		@current_object = Group.find(params[:id])
	end

	def destroy
		@current_object = Group.find(params[:id])
		if @current_object.delete
			flash[:notice] = I18n.t('item.destroy.flash_notice')
			redirect_to workspace_contacts_path(current_workspace.id)
		else
			flash[:error] = I18n.t('item.destroy.flash_error')
			redirect_to workspace_contacts_path(current_workspace.id)
		end
	end

	# Method to replace HTML for Assigned Options with Filter
  #
  # Usage URL:
  #
  # /people/filter?group_id=1
  def filtering_contacts
    group = Group.find(params[:group_id]) if !params[:group_id].blank?
    options = ""
		#raise current_workspace.contacts_workspaces.map{ |e| e.to_group_member }.delete_if{ |e| e['email'].first != params[:start_with] && params[:start_with] != "all"}.inspect
    current_workspace.contacts_workspaces.map{ |e| e.to_group_member }.delete_if{ |e| e['email'].first != params[:start_with] && params[:start_with] != "all"}.each do |mem|
      if group.nil? || !group.contacts_workspaces.map{ |e| e.to_group_member}.include?(mem)
        options = options+ "<option value = '#{mem['id'].to_s}'>#{mem['email']}</option>"
      end
    end
    render :update do |page|
      page.replace_html 'assignedOptions' ,:text => options
    end
  end

	def contacts
		if params[:contacts_workspaces_ids]
			if params[:to_do] == 'remove'
				params[:contacts_workspaces_ids].each do |e|
					cw=ContactsWorkspace.find(e)
					if cw.contactable_type == 'WebsiteContact'
						cw.contactable.delete
					end
					cw.delete
				end
			elsif params[:to_do] == 'link' && params[:group_id]
				params[:contacts_workspaces_ids].each do |e|
          a=Grouping.new(:group_id => params[:group_id].to_i, :contacts_workspace_id => e.to_i)
          a.save
				end
			elsif params[:to_do] == 'unsubscribed'
				params[:contacts_workspaces].each do |e|
					ContactsWorkspace.update_attributes(:state => 'unsubscribed')
				end
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
			if a.delete
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

  # Export members of the group to .csv file format
  #
  # This function is linked to an url and allows to generate and download the cvs file.
  def export_to_csv
    group = Group.find(params[:id])
    outfile = "group_people_" + Time.now.strftime("%m-%d-%Y") + ".csv"
		send_data(group.export_to_csv,
				:type => 'text/csv; charset=iso-8859-1; header=present',
				:disposition => "attachment; filename=#{outfile}")
  end

	# Method to unsubscribe from a newsletter for given email address
  #
	# TODO bl i
	#
  # Usage URL:
  #
  # /unsubscribe_for_newsletter?member_type=people&email=abc@abc.com
  #
  def unsubscribe
    contact_workspace = ContactsWorkspace.find(params[:cid])
    if contact_workspace.update_attribute(:state, 'unsubcribed')
      flash[:notice] = I18n.t('newsletter.unsubscribe.flash_notice')
      redirect_to request.path
    else
      flash[:error] = "Unable to unsubscribe. Please try again."
      redirect_to request.path
    end
  end

	protected
	
	def get_contacts_lists
		selected_contacts = @current_object.groupings.map{ |e| e.contacts_workspace }
		remaining_contacts = @current_object.workspace.contacts_workspaces.to_a - selected_contacts
		#raise selected_contacts.inspect
		@selected_members = selected_contacts.map{ |e| e.to_group_member } || []
		#raise @selected_members.inspect+'===='+@remaining_members.inspect
		@remaining_members = remaining_contacts.map{ |e| e.to_group_member } || []
	end
	
end
