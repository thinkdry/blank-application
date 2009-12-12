# == Schema Information
# Schema version: 20181126085723
#
# Table name: people
#
#  id            :integer(4)      not null, primary key
#  first_name    :string(255)
#  last_name     :string(255)
#  web_page      :string(255)
#  gender        :string(255)
#  notes         :text
#  email         :string(255)
#  primary_phone :string(255)
#  mobile_phone  :string(255)
#  fax           :string(255)
#  street        :string(255)
#  city          :string(255)
#  postal_code   :string(255)
#  country       :string(255)
#  company       :string(255)
#  job_title     :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_id       :integer(4)
#  newsletter    :boolean(1)
#  salutation    :string(255)
#  date_of_birth :datetime
#  origin        :string(255)
#

require 'country_select'

# This class is defining an object called 'Person'.
#
# It is actually the basic way to add a contact inside the application.
# This object is depending of an User object (the one who have created the Person object).
# After the creation, it is possible to create a Group item and add the contact (Perrson) to it,
# in order to share these contacts in a workspace.
#
class Person < ActiveRecord::Base

	# Relation N-1 with the polymorphic 'contacts_workspaces' table
  has_many :contacts_workspaces, :as => :contactable, :dependent => :destroy

  has_many :workspaces , :through => :contacts_workspaces
  # Validation of the presence of this attribute
  validates_presence_of :email
	# Validationof the size of this attribute
  validates_length_of :email, :within => 6..40
	# Validation of the format of this attribute
  validates_format_of :email, :with => RE_EMAIL_OK
#  validates_format_of       :primary_phone,  :mobile_phone, :with => /\A(#{NUM}){10}\Z/, :allow_blank => true
  validates_length_of       :primary_phone,  :mobile_phone, :in => 7..20, :allow_blank => true
  validates_format_of       :primary_phone,  :mobile_phone, :with => PHONE, :allow_blank => true
  # Validation of fields not in format of
  validates_not_format_of   :first_name, :last_name, :fax, :street, :city, :postal_code, :company,:job_title, :web_page, :notes,  :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true

  attr_accessor :model_name

  # Check with previously existing email for uniqueness
	#
	# This method checks if the email address is uniq for the user who has created the object.
	# TODO Set a correct validator for that
  #
  # Usage :
  # <tt>person.validate_uniqueness_of_email</tt>
  def validate_uniqueness_of_email
    if Person.exists?(:email=>self.email,:user_id => self.user_id)
      self.errors.add(:email, :taken)
      return false
    else
      return true
    end
  end

  # Return the full name of the contact (Person)
  def full_name
		return self.salutation.to_s + " " + self.last_name.to_s + " " + self.first_name.to_s
  end

	# Return the People format of the object (here, itself)
  def to_person
    person = self
    person.model_name = "Person"
    return person
  end

  # Assign Worksapces to current Person ( One Person can be associated with many Worksapces)
  #
  # Usage :
  # <tt>article.assoicated_workspaces ([workspace1.id, workspace2.id])</tt>
  # will assign workspaces to the Person
  def associated_workspaces(workspace_ids)
    tmp = workspace_ids || []
    self.contacts_workspaces.each do |k|
      k.destroy unless tmp.delete(k.workspace_id.to_s)
    end
    tmp.each do |w_id|
      if !ContactsWorkspace.exists?(:workspace_id => w_id, :contactable_id => self.id, :contactable_type => "Person")
        self.contacts_workspaces << contacts_workspaces.build(:workspace_id => w_id, :contactable_id => self.id, :contactable_type => "Person")
      end
    end
  end
end
