class GroupsController < ApplicationController
  require 'fastercsv'
  require 'csv'
  acts_as_ajax_validation
  acts_as_item do

    after :create, :update do
      @current_object.groupable_objects = params[:selected_Options]
    end
  end

  # Method to Export Members of Groups to .csv file format
  def export_group
    @group = Group.find(params[:id])
    @members = @group.members
    @outfile = "group_people_" + Time.now.strftime("%m-%d-%Y") + ".csv"
    csv_data = FasterCSV.generate do |csv|
      csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City", "Postal code", "Country", "Company", "Web page", "Job title", "Notes","Newsletter","Salutation","Date of birth","Subscribed on","Updated at"]
        @members.each do |member|
          csv << [
            member.first_name,
            member.last_name,
            member.email,
            member.gender,
            member.primary_phone,
            member.mobile_phone,
            member.fax,
            member.street,
            member.city,
            member.postal_code,
            member.country,
            member.company,
            member.web_page,
            member.job_title,
            member.notes,
            member.newsletter,
            member.salutation,
            member.date_of_birth,
            member.created_at,
            member.updated_at
          ]
      end
    end
    send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"
    #    flash[:notice] = "Export complete!"
  end
end
