# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	def small_item_in_list(item)
		# display all items by category
		# ...	
		content_tag :h2, item.title
		content_tag :p, item.description		
	end
end
