module CustomTags
  class Item < Liquid::Tag 
    #include ActionView::Helpers::UrlHelper
    def initialize(tag_name, markup, tokens)
     super 
      p markup
      @tag_name = tag_name
      @args = eval('{' + markup + '}')
    end

    def render(context)
      send(@args[:item].pluralize, @args)
    end

    ITEMS.each do |item|
      define_method item.pluralize.to_sym do |*args|
        options = args.extract_options!
        items = item.classify.constantize.get_da_objects_list(build_params(options.merge!(:items => [item])))
        str = ""
        items.each do |item|
          str += "<li><a href='/#{item.class.to_s.underscore}/#{item.title_sanitized}'>#{item.title}</a></li>"
          #str += "<li>"  item.title, "/#{item}/#{item.title_sanitized}") + "</li>"
        end
        return str
      end
    end

#  def items(*args)
#    options = args.extract_options!
#    options[:items] ||= @current_website.available_items.split(',')
#    search = Search.new(setting_searching_params(:from_params => build_params(options)))
#    items = search.do_search
#    str = ""
#    items.each do |item|
#      str += "<li>" + (link_to item.title, "/#{item.class.to_s.underscore}/#{item.title_sanitized}") + "</li>"
#    end
#    return str
#  end

  protected

    def build_params(options)
      options[:field] ||= 'created_at'
      options[:order] ||= 'desc'
      options[:limit] ||= 5
      hash = {
        :models => options[:items],
        :filter => { :field => options[:field], :way => options[:order]},
        :pagination => { :page => options[:page] || 1, :per_page => options[:limit]},
        :containers => {:website => [$current_website.id.to_s]},
        :user => $current_website.creator,
			  :permission => 'show',
        :opti => options[:opti] ? options[:opti] : 'skip_pag_but_filter'
      }
      hash
    end
    
  end
   Liquid::Template.register_tag('items', Item)
end
