atom_feed do |feed|
	feed.title "Workspaces list"
	feed.updated Time.now
	@current_objects.each do |task|
		feed.entry(task, :url => workspace_url(task.id)) do |entry|
			entry.title task.title
			entry.content("Creater : #{task.creator.full_name}" +"<br /><br /> Description : " + task.description + "<br /><br />" , :type => 'html')
		end
	end
end
