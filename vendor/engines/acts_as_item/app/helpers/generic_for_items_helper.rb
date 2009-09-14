module GenericForItemsHelper

	# Display Item in List for Editor
	def display_item_in_list_for_editor
		display_objects_list(:in_list_partial => 'generic_for_items/item_in_list_for_editor')
	end

	def display_generic_items_tab(partial_name= 'top_box')
    if current_workspace
        most_commented = GenericItem.from_workspace(current_workspace.id).consultable_by(current_user.id).most_commented.to_a
        best_rated = GenericItem.from_workspace(current_workspace.id).consultable_by(current_user.id).best_rated.to_a
        feed_items = FeedItem.from_workspace(current_workspace.id).consultable_by(current_user.id).latest.to_a
    else
        most_commented = GenericItem.consultable_by(current_user.id).most_commented.to_a
        best_rated = GenericItem.consultable_by(current_user.id).best_rated.to_a
        feed_items = FeedItem.consultable_by(current_user.id).latest.to_a
    end
    return render :partial => "generic_for_items/"+partial_name,
                :locals =>{:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items}
  end

end