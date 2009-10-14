module GenericForItemsHelper

	# Display Item in List for Editor
	def display_item_in_list_for_editor
		display_objects_list(:in_list_partial => 'generic_for_items/item_in_list_for_editor')
	end

	def display_generic_items_tab(partial_name= 'top_box')
		
    item_types = item_types_allowed_to(@current_user, 'show', current_workspace)
    most_commented = get_generic_objects(item_types, 'comments_number-desc')
    best_rated = get_generic_objects(item_types, 'rates_average-desc')
    if current_workspace
      latest = get_generic_objects(item_types,  'created_at-desc')
      feed_items = FeedItem.from_workspace(current_workspace.id).consultable_by(current_user.id).latest.to_a
      locals = {:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items, :latest => latest}
    else
      feed_items = FeedItem.consultable_by(current_user.id).latest.to_a
      locals = {:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items}
    end

    return render :partial => "generic_for_items/"+partial_name,
                :locals => locals

  end

end