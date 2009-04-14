class Person < ActiveRecord::Base
  include Authentication

  has_many :groupings, :as => :groupable
  has_many :member_in, :through => :groupings, :source => :group



  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK

  def full_name
		return self.last_name+" "+self.first_name
  end
end
