module GenericForItemsHelper

	# Display Item in List for Editor
	def display_item_in_list_for_editor
		display_objects_list(:in_list_partial => 'generic_for_items/item_in_list_for_editor')
	end

	def display_generic_items_tab(partial_name= 'top_box')
		latest = get_objects_list_with_search('item', 'created_at-desc', 5)
    most_commented = get_objects_list_with_search('item', 'comments_number-desc', 5)
    best_rated = get_objects_list_with_search('item', 'rates_average-desc', 5)
    if current_workspace
      feed_items = FeedItem.from_workspace(current_workspace.id).consultable_by(current_user.id).latest.to_a
    else
      feed_items = FeedItem.consultable_by(current_user.id).latest.to_a
    end
		locals = {:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items, :latest => latest}
    return render :partial => "generic_for_items/"+partial_name, :locals => locals
  end

end