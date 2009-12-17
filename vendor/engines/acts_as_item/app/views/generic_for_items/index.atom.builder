atom_feed do |feed|
	feed.title "My items list"
	feed.updated Time.now
	@paginated_objects.each do |task|
		feed.entry(task, :url => admin_article_url(task)) do |entry|
			entry.title task.title
			entry.content( "Description : " + task.description + "<br /><br />" + render( :partial => "admin/#{task.class.to_s.underscore.downcase.pluralize}/preview.html", :object =>task ), :type => 'html')
		end
	end
end
