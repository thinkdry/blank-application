# This controller is managing the different actions relative to the Group item.
#
# It is not using the mixin function called 'acts_as_item' from the ActsAsItem::ControllerMethods::ClassMethods,
# because the item is linked only to one workspace.
# By the way, it is not list with the content but in an other section called 'Contacts management'.
# TODO find a soltuion to manage item linked to just ONE workspace (with workspace_id field)
#

class GroupsController < ApplicationController

	acts_as_ajax_validation

  # Declaration of the ActAsCommentable plugin
	acts_as_commentable
  
	before_filter :permission_checking, :except => [:unsubscribe]

  before_filter :current_object, :only =>[:show, :edit, :update, :destroy]

	def index
    filter = params[:by] ||= 'created_at-desc'
    if params[:format].nil? || params[:format] == 'html'
      @paginated_objects = Group.paginate(:conditions => {:workspace_id => current_workspace.id}, :order => "#{filter.split('-').first} #{filter.split('-').last}", :per_page => get_per_page_value, :page => params[:page])
    end
    
    respond_to do |format|
			format.html{ render :partial => 'index', :layout => false && @no_div = true if request.xml_http_request?}
			format.xml { render :xml => Group.find(:all, :conditions => {:workspace_id => current_workspace.id}) }
			format.json { render :json => Group.find(:all, :conditions => {:workspace_id => current_workspace.id}) }
			format.atom {@current_objects = Group.find(:all, :conditions => {:workspace_id => current_workspace.id}); render :template => "groups/index.atom.builder", :layout => false }
		end
	end

	def new
		@current_object = Group.new
		@current_object.workspace_id = params[:workspace_id]
		get_contacts_lists
	end

	def edit
#		@current_object = Group.find(params[:id])
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
#		@current_object = Group.find(params[:id])
		if @current_object.update_attributes(params[:group])
      @current_object.groupable_objects = params[:selected_Options]
			flash[:notice] = I18n.t('item.edit.flash_notice')
			redirect_to workspace_group_path(params[:workspace_id], @current_object)
		else
			get_contacts_lists
			flash[:error] = I18n.t('item.edit.flash_error')
			render :action => :edit
		end
	end

	def show
#		@current_object = Group.find(params[:id])
	end

	def destroy
#		@current_object = Group.find(params[:id])
		if @current_object.destroy
			flash[:notice] = I18n.t('item.destroy.flash_notice')
			redirect_to workspace_groups_path(current_workspace.id)
		else
			flash[:error] = I18n.t('item.destroy.flash_error')
			redirect_to workspace_group_path(current_workspace.id, @current_object.id)
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

	protected

  def permission_checking
		no_permission_redirection unless @current_user && current_workspace && current_workspace.has_permission_for?('contacts_management', @current_user)
	end

	def get_contacts_lists
		selected_contacts = @current_object.groupings.map{ |e| e.contacts_workspace }.uniq
		remaining_contacts = @current_object.workspace.contacts_workspaces.to_a - selected_contacts
		#raise selected_contacts.inspect
		@selected_members = selected_contacts.map{ |e| e.to_group_member } || []
		#raise @selected_members.inspect+'===='+@remaining_members.inspect
		@remaining_members = remaining_contacts.map{ |e| e.to_group_member } || []
	end

  def current_object
    @current_object = Group.find(params[:id])
  end
end
