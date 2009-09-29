# == Schema Information
# Schema version: 20181126085723
#
# Table name: groups
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'fastercsv'

# This class is defining an object called 'Group'. It is close to an item but the difference is that
# a group can only be in one uniq workspace.
# 
# TODO to make a difference between an item in multiple ws and in one ws in order to include Group as an item
#
# You can use it to link different email addresses from the current user contacts.
# Thus, it becomes easy to send newsletters to these contacts, or to share these contacts inside a workpace.
#

class Group < ActiveRecord::Base

	# Relation N-1 to workspace
	belongs_to :workspace
	# Mixin to add ActsAsCommentable methods inside the model
	acts_as_commentable
	# Relation N-N to 'newsletters' table
  has_and_belongs_to_many :newsletters
	# Relation 1-N 
  has_many :groups_newsletters, :dependent => :delete_all
	# Relation N-1 to the 'groupings' table, defining the object composing the group
  has_many :groupings, :dependent => :delete_all
	# Relation N-1 to the 'groupings' table and scoping the User objects
  has_many :contacts_workspaces, :through => :groupings
  # Validation of the presence of these fields
  validates_presence_of	:title, :description
  # Validation of fields not in format of
	validates_not_format_of :title, :description ,  :with => /(#{SCRIPTING_TAGS})/
	
  # Setting the Grouping objects given as parameters
  # 
  # This method allows to manage directly the objects to link to this group and sent by the form.
	# Depending of the values retrieved from the paramter, it will create or delete Grouping objects.
	# The parameter has to be a array of string following the syntax :
	# - (object_name)_(object_id)
	#
	# Usage :
	# - @group.groupable_objects= ['User_1', 'Person_23', .... ]
  def groupable_objects= params 
    tmp = params.split(',') || []
    self.contacts_workspaces.each do |k|
      self.contacts_workspaces.delete(k) unless tmp.delete(k.id.to_s)
    end
    exists_cw_ids = self.contacts_workspaces.map{|cw| cw.id}
    tmp.each do |cw_id|
      if !exists_cw_ids.include?(cw_id.to_i)
        self.groupings << groupings.build(:group_id => self.id, :contacts_workspace_id => cw_id)
      end
    end
  end

	# Method return a CSV file with the group member inside
	def export_to_csv
    return FasterCSV.generate do |csv|
      csv << ["First name", "Last name", "Email", "Gender", "Primary phone", "Mobile phone", "Fax", "Street", "City",
				"Postal code", "Country", "Company", "Web page", "Job title", "Notes","Newsletter","Salutation",
				"Date of birth","Subscribed on","Updated at"]
      self.members.each do |member|
				csv << [member.first_name, member.last_name, member.email, member.gender, member.primary_phone,
						member.mobile_phone, member.fax, member.street, member.city, member.postal_code, member.country,
            member.company, member.web_page, member.job_title, member.notes, member.newsletter, member.salutation,
            member.date_of_birth, member.created_at, member.updated_at]
				end
			end
	end

  # List of the objects composing the Group, ordered by email
	#
	# This method will return a list of the objects composing the group,
	# converted with the 'to_person' method in order to be able to order the list properly.
	# By the way, it will allow to manage this list in a generic way.
  def members
    return self.contacts_workspaces.map{ |e| e.contactable.to_person }.sort!{ |a,b| a.email.downcase <=> b.email.downcase }
  end

end
