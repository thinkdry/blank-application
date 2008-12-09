atom_feed do |feed|
	feed.title "My items list"
	feed.updated Time.now
	@current_objects.each do |task|
		feed.entry task do |entry|
			entry.title task.title
			entry.content task.description, :type => 'html'
		end
	end
end