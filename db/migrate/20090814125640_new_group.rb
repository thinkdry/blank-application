class NewGroup < ActiveRecord::Migration
  def self.up
		remove_column :groups, :rates_average
		remove_column :groups, :comments_number
		remove_column :groups, :viewed_number
		add_column :groups, :workspace_id, :integer
		remove_column :groupings, :groupable_type
		remove_column :groupings, :groupable_id
		add_column :groupings, :contacts_workspace_id, :integer
		# Remove group as Item
		Grouping.delete_all
		Workspace.all.each do |w|
			if w.ws_items.include?('group')
				w.ws_items = (w.ws_items.split(',') - ['group'])
				w.save
			end
		end
		Item.find(:all, :conditions => { :itemable_type => 'Group' }).each{ |e| e.delete }
		create_table :contacts_workspaces do |t|
			t.integer :workspace_id
			t.integer :contactable_id
			t.string :contactable_type
			t.string :state
			t.timestamps
		end
	end

  def self.down
		
  end
end
