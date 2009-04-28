class PeopleController < ApplicationController
  require 'fastercsv'
  require 'csv'
  
  before_filter :get_people, :only=>[:index,:ajax_index]
  PER_PAGE = 10
  acts_as_ajax_validation

  make_resourceful do
    actions :show, :create, :new, :edit, :update, :destroy
  end

  def index

  end
  
  def ajax_index
    
    render :partial=> 'person' ,:layout=>false
  end

  def filter
    @group = Group.find(params[:group_id]) if !params[:group_id].blank?
    options = ""
    for mem in Group.members_to_subscribe(params[:start_with])
      if @group.nil? or !@group.members.include?(mem)
        options = options+ "<option value = '#{mem.class.to_s.downcase}_#{mem.id}'>#{mem.email}</option>"
      end
    end
    render :update do |page|
      page.replace_html 'assignedOptions' ,:text => options
    end
  end

  def export_people
    @people = Person.find(:all)
    @outfile = "people_" + Time.now.strftime("%m-%d-%Y") + ".csv"
    csv_data = FasterCSV.generate do |csv|
      csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes","Subscribed on","Updated at"]
      @people.each do |person|
        csv << [
          person.first_name,
          person.last_name,
          person.email,
          person.gender,
          person.primary_phone,
          person.mobile_phone,
          person.fax,
          person.street,
          person.city,
          person.postal_code,
          person.country,
          person.company,
          person.web_page,
          person.job_title,
          person.notes,
          person.created_at,
          person.updated_at
        ]
      end
    end
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"
    #    flash[:notice] = "Export complete!"
  end

  def import_people

    unless request.get?
      if !params[:people][:csv].blank? and File.extname(params[:people][:csv].original_filename) == '.csv'
        begin
          @parsed_file=CSV::Reader.parse(params[:people][:csv]).to_a
          first_name =['first name','firstname','first-name','name','prénom']
          last_name =['last name','lastname','last-name','nom']
          email = ['email','e-mail','e mail','email address','email-address','e-mail address']
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
            col = col.downcase
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
              person = Person.new(details)
              person.user_id = current_user.id
              if !person.save
                @unsaved_emails << person.email
              end
            end
          end
          flash.now[:notice] = I18n.t('people.import_people.saved_records_flash_notice') if @unsaved_emails.empty?
          flash.now[:error] = I18n.t('people.import_people.unsaved_records_flash_error1')+'<b> '+@unsaved_emails.join(',')+' </b>'+I18n.t('people.import_people.unsaved_records_flash_error2') if !@unsaved_emails.empty?
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

  def get_empty_csv
    csv_data = FasterCSV.generate do |csv|
      csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes"]
    end
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=contact.csv"
  end

  private

  def get_people
    @people = Person.paginate(
      :page => params[:page],
      :order => :email,
      :per_page => get_per_page_value
    )
  end
end
