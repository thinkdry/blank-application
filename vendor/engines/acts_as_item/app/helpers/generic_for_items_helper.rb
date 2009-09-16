module GenericForItemsHelper

	# Display Item in List for Editor
	def display_item_in_list_for_editor
		display_objects_list(:in_list_partial => 'generic_for_items/item_in_list_for_editor')
	end

	def display_generic_items_tab(partial_name= 'top_box')
#    if current_workspace
#        most_commented = GenericItem.from_workspace(current_workspace.id).consultable_by(current_user.id).most_commented.to_a
#        best_rated = GenericItem.from_workspace(current_workspace.id).consultable_by(current_user.id).best_rated.to_a
#        feed_items = FeedItem.from_workspace(current_workspace.id).consultable_by(current_user.id).latest.to_a
#        latest = GenericItem.from_workspace(current_workspace.id).latest
#        locals = {:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items, :latest => latest}
#    else
#        most_commented = GenericItem.consultable_by(current_user.id).most_commented.to_a
#        best_rated = GenericItem.consultable_by(current_user.id).best_rated.to_a
#        feed_items = FeedItem.consultable_by(current_user.id).latest.to_a
#        locals = {:most_commented => most_commented, :best_rated => best_rated, :feed_items => feed_items}
#    end
    
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

  def get_generic_objects(item_types, filter)
    generic_items =[]
    params = build_hash_from_params({:by => filter, :page => 1, :per_page => 5})
        item_types.each{|item|
          model_const = item.classify.constantize
          generic_items += model_const.get_da_objects_list(params).to_a
        }
    return generic_items.sort!{|a, b| b.send(filter.split('-').first) <=> a.send(filter.split('-').first)}[0,5]
  end
end