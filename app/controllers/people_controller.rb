require 'fastercsv'
require 'csv'

# This controller manage the actions linked to the Person object.
#
class PeopleController < ApplicationController

	# Method getting a mixin managing the form validation with AJAX
	acts_as_ajax_validation

	# Method defined in the ActsAsItem:ControllerMethods:ClassMethods (see that library fro more information)
  make_resourceful do
    actions :show, :new, :edit, :update, :destroy

		response_for :new do |format|
			format.html { redirect_to (current_workspace ? new_workspace_person_path(current_workspace.id) : new_person_path) }
		end

		response_for :edit do |format|
			format.html { redirect_to (current_workspace ? edit_workspace_person_path(current_workspace.id, @person.id) : edit_person_path(@person.id)) }
		end

		response_for :show, :update do |format|
			format.html { redirect_to (current_workspace ? workspace_person_path(current_workspace.id, @person.id) : person_path(@person.id)) }
		end

		response_for :destroy do |format|
			format.html { redirect_to (current_workspace ? workspace_contacts_groups_path(current_workspace.id) : people_path) }
		end

  end

  # Method to create a New Person
  def create #:nodoc:
    @person = Person.new(params[:person])
    @person.user_id = current_user.id
    if @person.validate_uniqueness_of_email
			if@person.save
			# If in a workspace, need to put the contacts_workspace link
				if current_workspace
					ContactsWorkspace.create(
							:workspace_id => current_workspace.id,
							:contactable_id => @person.id,
							:contactable_type => @person.class_to_s,
							:state => nil
						)
				end
				flash[:notice] = 'Person saved'
				redirect_to person_path(@person)
			else
				flash[:error] = 'Person non saved'
				render :action=>'new'
			end
		else
			flash[:error] = 'You have already a contact with that email.'
			if current_workspace
				tmp = Person.find(:first, :conditions => { :user_id => @current_user.id, :email => person.email })
				ContactsWorkspace.create(
						:workspace_id => current_workspace.id,
						:contactable_id => tmp.id,
						:contactable_type => 'Person'
					)
			end
    end
		redirect_to (current_workspace ? workspace_person_path(current_workspace.id, @person.id) : person_path(@person.id))
  end

  # Method to Show all People 
  def index #:nodoc:
		params[:restriction] ||= 'people'
		params[:type] ||= {'newsletter' => '0'}
		@people = @current_user.get_contacts_list(params[:restriction], 'group_member', params[:type][:newsletter] == '1').paginate(:per_page => get_per_page_value, :page => params[:page])
  end

  # Method to all People for Ajax Pagination
  def ajax_index #:nodoc:
		params[:restriction] ||= 'people'
		params[:type] ||= {'newsletter' => '0'}
    @people = @current_user.get_contacts_list(params[:restriction], 'group_member', params[:type][:newsletter] == '1').paginate(:per_page => get_per_page_value, :page => params[:page])
    render :partial => 'people_list', :layout => false
  end

  # Method to Export People to .csv file format
  #
  # Usage URL:
  #
  # /people/export_people
  def export_people
		params[:restriction] ||= 'people'
		params[:type] ||= {'newsletter' => '0'}
		@people = @current_user.get_contacts_list(params[:restriction], 'people', params[:type][:newsletter] == '1')
		@outfile = "people_" + Time.now.strftime("%m-%d-%Y") + ".csv"
		csv_data = FasterCSV.generate do |csv|
			csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes","Newsletter","Salutation","Date of birth","Subscribed on","Updated at"]
			@people.each do |person|
				csv << [person.first_name, person.last_name, person.email, person.gender, person.primary_phone, person.mobile_phone, person.fax, person.street, person.city, person.postal_code, person.country, person.company, person.web_page, person.job_title, person.notes, person.newsletter, person.salutation, person.date_of_birth, person.created_at, person.updated_at]
			end
		end
		send_data csv_data, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment; filename=#{@outfile}"
		#flash[:notice] = "Export complete!"
  end

  # Method to Import People from a .csv file format
  #
  # Usage URL:
  #
  # /people/import_people
  def import_people
    unless request.get?
      if !params[:people].blank? and !params[:people][:csv].blank? and File.extname(params[:people][:csv].original_filename) == '.csv'
        begin
          @parsed_file=CSV::Reader.parse(params[:people][:csv]).to_a
          first_name =['first name','firstname','first-name','name','prénom']
          last_name =['last name','lastname','last-name','nom']
          email = ['email','e-mail','e mail','email address','email-address','e-mail address','emailaddress']
          gender = ['gender']
          primary_phone = ['primary phone','primaryphone','primary-phone']
          mobile_phone = ['mobile phone','mobilephone','mobile-phone']
          fax = ['fax']
          street = ['street']
          city = ['city']
          postal_code = ['postal code','postalcode','postal-code','code-postal','code postal','codepostal']
          country = ['country']
          company = ['company']
          web_page = ['web page','webpage','web-page']
          job_title = ['job title','jobtitle','job-title']
          notes = ['notes']
          cols_order =[]
          @parsed_file[0].each do |col|
            col = col.scan(/\w+/).to_s.downcase
            if first_name.include?(col)
              cols_order << 'first_name'
            elsif last_name.include?(col)
              cols_order << 'last_name'
            elsif email.include?(col)
              cols_order << 'email'
            elsif gender.include?(col)
              cols_order << 'gender'
            elsif primary_phone.include?(col)
              cols_order << 'primary_phone'
            elsif mobile_phone.include?(col)
              cols_order << 'mobile_phone'
            elsif fax.include?(col)
              cols_order << 'fax'
            elsif street.include?(col)
              cols_order << 'street'
            elsif city.include?(col)
              cols_order << 'city'
            elsif postal_code.include?(col)
              cols_order << 'postal_code'
            elsif country.include?(col)
              cols_order << 'country'
            elsif company.include?(col)
              cols_order << 'company'
            elsif web_page.include?(col)
              cols_order << 'web_page'
            elsif job_title.include?(col)
              cols_order << 'job_title'
            elsif notes.include?(col)
              cols_order << 'notes'
            else
              cols_order << ''
            end
          end
          @unsaved_emails = []
					empty_emails = 0
          @parsed_file.each_index do |index|
            if index != 0
              i = 0
              details = {}
              @parsed_file[index].each do |value|
                if cols_order[i] != '' and !cols_order[i].nil?
                  details[cols_order[i]] = value
                end
                i+=1
              end
              if !details['email'].nil?
                person = Person.new(details.merge({:newsletter => true}))
                person.user_id = current_user.id
                person.origin = "CSV importation"
                if person.validate_uniqueness_of_email
									if person.save
                  
									else
										@unsaved_emails << person.email
									end
								elsif person.valid?
										if current_workspace
											tmp = Person.find(:first, :conditions => { :user_id => @current_user.id, :email => person.email })
											ContactsWorkspace.create(
													:workspace_id => current_workspace.id,
													:contactable_id => tmp.id,
													:contactable_type => 'Person'
											)
										end
								else
									@unsaved_emails << person.email
								end
							else
								empty_emails +=1
							end
            end
          end
          flash.now[:notice] = I18n.t('people.import_people.saved_records_flash_notice') if @unsaved_emails.empty? && empty_emails == 0
          flash.now[:error] = I18n.t('people.import_people.unsaved_records_flash_error1')+'<b> '+@unsaved_emails.join(',')+' </b>'+I18n.t('people.import_people.unsaved_records_flash_error2') if !@unsaved_emails.empty?
					flash.now[:error] = "#{empty_emails} contacts n'ont pas été sauvegardés car l'email était vide." if empty_emails > 0
        rescue Exception => e
          logger.error ">>>>>>>>>>>>>>>>>>>"
          logger.error " Problem while parsing csv file "+ e
          flash.now[:error] = I18n.t('people.import_people.csv_parser_error')
        end
      else
        flash.now[:error] = I18n.t('people.import_people.wrong_file_flash_error')
      end
    end
  end

  # Generate a Empty .csv File
  #
  # Usage URL:
  #
  # /people/get_empty_csv
  def get_empty_csv
    csv_data = FasterCSV.generate do |csv|
      csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes"]
    end
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=contact.csv"
  end

  # Update Newsletter Column for Subscribe/Unsubscribe
  #
  # Usage URL:
  #
  # /people/update_newsletter_column
  def update_newsletter_column
    @object = params[:type].classify.constantize.find(params[:id])
    @object.update_attribute(:newsletter, params[:newsletter])
    render :update do |page|
      if params[:newsletter] == "true"
        page.alert("#{@object.email} will receive newsletters from now onwards")
      else
        page.alert("#{@object.email} will not receive newsletters from now onwards")
      end
    end
  end
  
end
