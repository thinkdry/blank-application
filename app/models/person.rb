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

	# Relation N-1 to 'groupings' table
  has_many :groupings, :as => :groupable, :dependent => :delete_all
  # Validation of the presence of this attribute
  validates_presence_of :email
	# Validationof the size of this attribute
  validates_length_of :email, :within => 10..40
	# Validation of the format of this attribute
  validates_format_of :email, :with => RE_EMAIL_OK
  validates_format_of       :primary_phone,  :mobile_phone, :with => /\A(#{NUM}){10}\Z/, :allow_blank => true
  # Validation of fields not in format of
  validates_not_format_of   :first_name, :last_name, :fax, :street, :city, :postal_code, :company,:job_title, :web_page, :notes,  :with => /(#{SCRIPTING_TAGS})/, :allow_blank => true

  attr_accessor :model_name

  # Check with previously existing email for uniqueness
	#
	# This method checks if the email address is uniq for the user who has created the object.
	# TODO Put it has AJAX validation
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
  def to_people
    people = self
    people.model_name = "Person"
    return people
  end

  # Method returning the object mapped into a Hash with just some attributes
  def to_group_member
    return { :model => 'Person', :id => self.id, :email => self.email, :first_name => self.first_name, :last_name => self.last_name, :origin => self.origin, :created_at => self.created_at, :newsletter => self.newsletter }
  end

end
