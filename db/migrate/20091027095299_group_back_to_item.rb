class GroupBackToItem < ActiveRecord::Migration
	
  def self.up
    add_column :groups, :rates_average, :integer, :default => 0
		add_column :groups, :viewed_number, :integer, :default => 0
		Group.all.each do |e|
			ItemsWorkspace.create(:workspace_id => e.workspace_id, :itemable_type => 'Group', :itemable_id => e.id)
		end
  end

  def self.down
		
  end
end
