module KeywordsHelper

	# Item Keywords Fields
	#
  #
  # Usage :
  # <tt>item_keywords_fields(form, article)</tt>
  #
  # will return item keywords fields for the artile
	def item_keywords_fields(form, object)
    render :partial => "keywords/keywords_fields", :locals => { :f => form, :object => object }
	end

	def keywords_links_list_for(object)
		return  ((l=object.keywords_list).size > 0) ? 
		        l.split(',').map{|e| link_to(e.strip, admin_searches_path('q' => e,'cat'=>'item'), :class => "tag")} :
		        ""
	end

end