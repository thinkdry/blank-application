class Workspace < ActiveRecord::Base
	
	has_many :users_workspaces, :dependent => :delete_all
	has_many :users, :through => :users_workspaces
	
	has_many :items, :dependent => :delete_all
  has_many_polymorphs :itemables, :from => [:artic_files], :through => :items
	
	validates_presence_of :name
	validates_associated :users_workspaces
	
	after_update :save_users_workspaces
	
	def new_user_attributes= user_attributes
	  user_attributes.each do |attributes| 
      users_workspaces.build(attributes) 
    end 
  end
  
  def existing_user_attributes= user_attributes
    users_workspaces.reject(&:new_record?).each do |uw|
      attributes = user_attributes[uw.id.to_s]
      attributes ? uw.attributes = attributes : users_workspaces.delete(task)
    end
  end
  
  def save_users_workspaces 
    users_workspaces.each do |uw| 
      uw.save(false) 
    end 
  end 
  
end
