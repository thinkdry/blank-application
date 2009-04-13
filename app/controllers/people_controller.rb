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
    @people = Person.find(:all,:conditions=>["email REGEXP ?","^([#{params[:start_with]}])"])
    options = ""
    for person in @people
      if @group.nil? or !@group.people.exists?(person)
        options = options+ "<option value = '#{person.id}'>#{person.email}</option>"
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
        @saved_emails = []
        @unsaved_emails = []
        i=0
        @parsed_file=CSV::Reader.parse(params[:people][:csv])
        @parsed_file.each  do |row|
          if i != 0
            person = Person.new
            person.first_name = row[0]
            person.last_name = row[1]
            person.email = row[2]
            person.gender = row[3]
            person.primary_phone = row[4]
            person.mobile_phone = row[5]
            person.fax = row[6]
            person.street = row[7]
            person.city = row[8]
            person.postal_code = row[9]
            person.country = row[10]
            person.company = row[11]
            person.web_page = row[12]
            person.job_title = row[13]
            person.notes = row[14]
            if person.save
              @saved_emails << person.email
            else
              @unsaved_emails << person.email
            end
          else
            if !(row == ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes"])
              flash[:error] = I18n.t('people.import_people.title_order_flash_error')
              return
            end
          end
          i += 1
        end
        flash[:notice] = I18n.t('people.import_people.saved_records_flash_notice1')+'<b> '+@saved_emails.join(',')+' </b>'+I18n.t('people.import_people.saved_records_flash_notice2') if !@saved_emails.empty?
        flash[:error] = I18n.t('people.import_people.unsaved_records_flash_notice1')+'<b> '+@unsaved_emails.join(',')+' </b>'+I18n.t('people.import_people.unsaved_records_flash_notice2') if !@unsaved_emails.empty?
      else
        flash[:error] = I18n.t('people.import_people.wrong_file_flash_error')
      end
    end
  end

  private

  def get_people
    @people = Person.paginate(
      :page => params[:page],
      :order => :email,
      :per_page => PER_PAGE
    )
  end
end
