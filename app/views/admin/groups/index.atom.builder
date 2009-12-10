atom_feed do |feed|
	feed.title "Groups list"
	feed.updated Time.now
	@current_objects.each do |task|
		feed.entry(task, :url => workspace_group_url(task.workspace_id, task.id)) do |entry|
			entry.title task.title
			entry.content( "Description : " + task.description + "<br /><br />" , :type => 'html')
		end
	end
end
