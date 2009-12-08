module Admin::BlankListsHelper

	# Display the content tabs list of an object type given
  #
	# This helper method gets the objects list to display,
	# and generates the HTML code displaying that list,
	# inside a content tabs list.
  #
  # Parameters :
  # - default_tab: String defining the object type to display bu default
  # - tabs_list: Array of string defining the different objects to link to the tabs
  # - url_base: String defining the URL getting the objects list
	# - list_partial: String defining the partial to use for the object list
	#
	# Usage :
  # display_tabs_items_list(
	#		:default_tab => params[:item_type],
  #		:tabs_list => get_allowed_item_types(current_workspace),
  #		:url_base => 'ajax_items_path',
  #		:list_partial => 'generic_for_items/index''article', paginated_objects, ajax_items_path('article')
	# )
  def display_tabs_objects_list(*args)
		options2 = args.extract_options!
		item_types = options2[:tabs_list]
		item_type = options2[:default_tab] || item_types.first.to_s.pluralize
    content = String.new
		#raise item_types.inspect
		if item_type.blank?
			return I18n.t('item.common_word.no_item_types')
		else
			item_types.map{ |item| item.camelize }.each do |item_model|

        # each li got a different content
        li_content = String.new

				url = self.send(options2[:url_base].to_sym, item_model.classify.constantize)
				item_page = item_model.underscore.pluralize
				options = {}
				options[:class] = 'selected' if (item_type == item_page)
				options[:id] = item_model.underscore

        li_content += link_to_remote(item_model.classify.constantize, :html => { :class => 'munuElement'}, :method=>:get, :update => "object-list", :url => url, :before => "selectItemTab('" + item_model.underscore + "')")
				content += content_tag(:li,	li_content,	options)
			end
			return content_tag(:ul, content, :id => :tabs) + render(:partial => options2[:list_partial], :layout => false)
		end
	end

	# Display an objects list depending of params and set the filtering and pagination part
  #
	# Parameters :
	# - collection: Objects list
	# - in_list_partial: String defining the partial representing an object in the list
	# - ajax_url: String defining the URL for AJAX call
	# - ordering_fields : Array of strings defining the fields for filtering these objects
	# - output_formats: Array of strings defining the output formats available
	# - no_div: Booelan defining if the results are inside a div (direct call) or no (AJAX calls)
	# 
  # Usage :
  # display_items_list(
	#   :collection => @paginated_objects,
	#   :in_list_partial => 'generic_for_items/item_in_list',
	#   :ajax_url => request.path+'?'+request.url.split('?').last,
	#   :ordering_fields => ['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'],
	#		:output_formats => ['xml', 'json', 'atom'],
	#		:no_div => @no_div
	# )
	def display_objects_list(*args)
		options = args.extract_options!
	  content = render :partial => 'admin/blank_lists/objects_list', :locals => {
				:in_list_partial => options[:in_list_partial],
				:ajax_url => options[:ajax_url],
				:ordering_fields => options[:ordering_fields],
				:output_formats => options[:output_formats],
        :output_formats_url => options[:output_formats_url]
			}
		if options[:no_div]
			return content
		else
			return content_tag(:div, content, :id => "object-list")
		end
	end

	# Display the dry objects list
  #
	# Parameters :
	# - items_list: Array of objects
	# - partial_used: String defining the partial to use
	#
  # Usage :
  #   display_items_in_list(items_list)
  def display_item_in_list(items_list, partial_used)
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Display the bar for filtering
	#
	# Parameters :
  # - ordering_fields_list: Array of string defining the fields to order
  # - ajax_url: String defining the URL for AJAX call on the list
  # - refreshed_div: String defining the div to refresh with the AJAX call
  # - partial_used: String deifning the partial used for the classify bar
  #
  # Usage :
  # display_classify_bar(['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'], ajax_url, 'object-list')</tt>
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='admin/blank_lists/classify_bar')
		render :partial => partial_used, :locals => {
      :ordering_fields_list => ordering_fields_list,
      :ajax_url => ajax_url,
      :refreshed_div => refreshed_div
		}
	end

	# Method cleaning the URL
	def safe_url(url, params)
		# TODO find a way to manage with AJAX params
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
    classify_url = (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')
		return classify_url.split('&').delete_if{|p| p==''}.join('&')
#    return url+'/?'+params.join('&')
	end

  # Method to render a specific partial if the file is existing
  #
  # Usage :
	# get_specific_partial('article', preview, article_object)
  def get_specific_partial(item_type, partial, object)
    if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
      render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
    else
      render :nothing => true
    end
  end

	def topbox(*arg)
		options = arg.extract_options!
		res = {}
		i=0
		options[:tabs].each do |k, v|
			res[0] = get_objects_list(k.to_s, v.split('-').first, v.split('-').last, options[:limit])
			i += 1
		end
		return render :partial => "generic_for_items/"+options[:partial_name], :locals => res
	end

	def toplist(*arg)
		options = arg.extract_options!

	end


end