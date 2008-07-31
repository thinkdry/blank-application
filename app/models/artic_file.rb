class ArticFile < ActiveRecord::Base
	
	acts_as_state_machine :initial => :public, :column => 'state'
	state :private
	state :public
	
	event :put_public do
		transitions :from => :private, :to => :public
	end
  
	event :put_private do
		transitions :from => :public, :to => :private
  end
	
	belongs_to :users
	
	file_column :file_path
	
	validates_presence_of	:title,
		:description,
		:file_path
	
	def associated_workspaces= workspace_ids
		self.workspaces.delete_all
		workspace_ids.each do |w|
			self.items.build(:workspace_id => w)
    end
  end
	
	def file_type
		self.file_path.split('.').last
  end
	
	
end
