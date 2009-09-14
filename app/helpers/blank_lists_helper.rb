module BlankListsHelper

	# Dislay of the given item type in content tabs list
  #
	# This helper method gets the item list to display,
	# and generates the HTML code displaying that list,
	# inside a content tabs list.
  #
  # Parameters :
  # - item_type: String defining the item type to display
  # - items_list:
  # - ajax_url: ajax item path for the item_type
	#
	# Usage :
  # display_tabs_items_list('article', paginated_objects, ajax_items_path('article'))
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

        tip_option = {}
        tip_option[:id] = "tip_" + item_model.underscore
        tip_option[:style] = "display:none;"
        tip_option[:class] = "tipTitle"

        li_content += link_to_remote(image_tag(item_model.classify.constantize.icon_48),:method=>:get, :update => "object-list", :url => url, :before => "selectItemTab('" + item_model.underscore + "')")
        li_content += content_tag(:div, item_model.classify.constantize.label , tip_option)
        li_content += "<script type='text/javascript'>
                      //<![CDATA[
                        new Tip('" + item_model.underscore + "',  $('tip_" + item_model.underscore + "'),
                            { effect: 'appear',
                              duration: 1,
                              delay:0,
                              hook: { target: 'topMiddle', tip: 'bottomMiddle' },
                              hideOn: { element: 'tip', event: 'mouseout' },
                              stem: 'bottomMiddle',
                              hideOthers: 'true',
                              hideAfter: 1,
                              width: 'auto',
                              border: 1,
                              offset: { x: 0, y: 3 },
                              radius: 0
                            });
                      //]]>
                    </script>"
				content += content_tag(:li,	li_content,	options)
			end
			return content_tag(:ul, content, :id => :tabs) + render(:partial => options2[:list_partial], :layout => false)
		end
	end

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_list(items_list, ajax_url)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  # - ajax_url: ajax item path for the item_type
	def display_objects_list(*args)
		options = args.extract_options!
	  content = render :partial => 'blank_lists/objects_list', :locals => {
				:in_list_partial => options[:in_list_partial],
				:ajax_url => options[:ajax_url],
				:ordering_fields => options[:ordering_fields],
				:output_formats => options[:output_formats],
			}
		if options[:no_div]
			return content
		else
			return content_tag(:div, content, :id => "object-list")
		end
	end

	# Items List
  #
  # Usage:
  #
  # <tt>display_items_in_list(items_list)</tt>
  #
  # will return list of items for given item_type with div 'object-list'
  #
  # - items_list: list of items to be displayed for the tab
  def display_item_in_list(items_list, partial_used)
		@i = 0
	  render :partial => partial_used, :collection => items_list
  end

  # Classify Bar for Ordering, Filtering Items
  #
  # Usage:
  #
  # <tt>display_classify_bar(['created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'], ajax_url, 'object-list')</tt>
  #
  # will return classify bar for item list with option to filter on fields
  #
  # Parameters:
  #
  # - ordering_fields_list: 'created_at', 'comments_number', 'viewed_number', 'rates_average', 'title'
  # - ajax_url: url to be passed to be called on click of item
  # - refreshed_dv: objects-list
  # - partial_used : 'items/classify_bar'
	def display_classify_bar(ordering_fields_list, ajax_url, refreshed_div, partial_used='blank_lists/classify_bar')
		render :partial => partial_used, :locals => {
      :ordering_fields_list => ordering_fields_list,
      :ajax_url => ajax_url,
      :refreshed_div => refreshed_div
		}
	end

	# Safe Url for Classify Bar
	def safe_url(url, params)
		# TODO generic allowing to replace params in url
		# trick, work just for classify_bar case
		prev_params = (a=request.url.split('?')).size > 1 ? '?'+a.last : ''
		#raise request.url.split('?').size.inspect
		return (url+prev_params).split(params.first.split('=').first).first + ((url+prev_params).include?('?') ? '&' : '?') +params.join('&')
#    return url+'/?'+params.join('&')
	end

  # Render Specific Partial according to Item Type passed
  #
  # Usage get_specific_partial('article', preview, article_object)
  #
  # will render the partial depending on the item_type
  def get_specific_partial(item_type, partial, object)
    if File.exists?(RAILS_ROOT+'/app/views/'+object.class.to_s.downcase.pluralize.underscore+"/_#{partial}.html.erb")
      render :partial => "#{object.class.to_s.downcase.pluralize.underscore}/#{partial}", :object => object
    else
      render :nothing => true
    end
  end

end