class Person < ActiveRecord::Base
  include Authentication

  has_many :groupings, :as => :groupable, :dependent => :delete_all

  has_many :member_in, :through => :groupings, :source => :group

  #Validations
  validates_presence_of     :email

  validates_length_of       :email,    :within => 6..100

  #validates_uniqueness_of   :email,    :case_sensitive => false

  validates_format_of       :email,    :with => RE_EMAIL_OK

  # Check with previously existing email for uniqueness
  def validate_uniqueness_of_email
    Person.exists?(:email=>self.email,:user_id => self.user_id)
    if Person.exists?(:email=>self.email,:user_id => self.user_id)
      self.errors.add(:email, :taken)
      return false
    else
      return true
    end
  end

  # Full Name of the Person 'Last Name First Name'
  def full_name
		return self.last_name.to_s+" "+self.first_name.to_s
  end

  # People Object
  def to_people
    return self
  end

  # Person to be Group Member
  def to_group_member
    return { :model => 'Person', :id => self.id, :email => self.email, :first_name => self.first_name, :last_name => self.last_name, :origin => self.origin, :created_at => self.created_at, :newsletter => self.newsletter }
  end

end
