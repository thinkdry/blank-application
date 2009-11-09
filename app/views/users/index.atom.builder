atom_feed do |feed|
	feed.title "Users list"
	feed.updated Time.now
	@current_objects.each do |task|
		feed.entry(task, :url => user_url(task.id)) do |entry|
			entry.title task.login
			entry.content("Name : #{task.full_name}" +"<br /> Email : #{task.email} <br /> Address: #{task.address}", :type => 'html')
		end
	end
end
