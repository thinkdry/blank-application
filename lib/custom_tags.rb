module CustomTags

  ITEMS.each do |item|
    class_name = "#{item.camelize}tag"
    Object.const_set(class_name, Class.new(Liquid::Tag) {
      def initialize(tag_name, markup, tokens)
        super 
        @tag_name = tag_name
        @args = eval('{' + markup + '}')
      end
      
      def render(context)
        items = @tag_name.classify.constantize.get_da_objects_list(build_params(@args.merge!(:items => [@tag_name.singularize])))
        str = ""
        items.each do |i|
          str += "<li><a href='/#{i.class.to_s.underscore}/#{i.title_sanitized}'>#{i.title}</a></li>"
          #str += "<li>"  item.title, "/#{item}/#{item.title_sanitized}") + "</li>"
        end
        return str
      end

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
    })
    Liquid::Template.register_tag(item.pluralize, class_name.classify.constantize)
  end

  class MenuGenerator < Liquid::Tag
    def initialize(tag_name, markup, tokens )
      super
      @tag_name = tag_name
      @args = eval('{'+ markup +'}')  
    end
    
    def render(context)
      menu_generator(@args)
    end

    def menu_generator(args)
      str = ""
      @menus = $current_website.menus
      ul = args[:ul] ? "<ul id=#{args[:ul]} class=#{args[:ul]}>" : '<ul>'
      li = args[:li] ? "<li id=#{args[:li]} class=#{args[:li]}>" : '<li>'
      current = args[:current] ? "<li id=#{args[:current]} class=#{args[:current]}>" : '<li>'
      str += ul
      @menus.roots.each do |root|
       str += li + "<a href=#{root.title_sanitized.to_s == '' ? '#' : '/' + root.title_sanitized}>#{root.name}</a>"
       #str += li + "#{link_to root.name, (root.title_sanitized.to_s == '' ? '#' : '/' + root.title_sanitized) }"
       str += root.children.blank? ? '</li>' : create_child(root) + '</li>'
      end
      str += '</ul>'
    end

    def create_child(object)
      str = ""
      str = '<ul id="' + object.name + '">'
      object.children.each do |child|
        str += "<li><a href=#{child.title_sanitized.to_s == '' ? '#' : '/' + child.title_sanitized}>#{child.name}</a>"
        #str += "<li>#{link_to child.name, (child.title_sanitized.to_s == '' ? '#' : '/' + child.title_sanitized)}"
        str += child.children.blank? ? '</li>' : create_child(child) + '</li>'
      end
      str += '</ul>'
    end
  end
  Liquid::Template.register_tag('menu_generator', MenuGenerator)
#  class Item < Liquid::Tag 
#    #include ActionView::Helpers::UrlHelper
#    def initialize(tag_name, markup, tokens)
#     super 
#      @tag_name = tag_name
#      @args = eval('{' + markup + '}')
#    end

#    def render(context)
#      send(@args[:item].pluralize, @args)
#    end

#    ITEMS.each do |item|
#      define_method item.pluralize.to_sym do |*args|
#        options = args.extract_options!
#        items = item.classify.constantize.get_da_objects_list(build_params(options.merge!(:items => [item])))
#        str = ""
#        items.each do |item|
#          str += "<li><a href='/#{item.class.to_s.underscore}/#{item.title_sanitized}'>#{item.title}</a></li>"
#          #str += "<li>"  item.title, "/#{item}/#{item.title_sanitized}") + "</li>"
#        end
#        return str
#      end
#    end

##  def items(*args)
##    options = args.extract_options!
##    options[:items] ||= @current_website.available_items.split(',')
##    search = Search.new(setting_searching_params(:from_params => build_params(options)))
##    items = search.do_search
##    str = ""
##    items.each do |item|
##      str += "<li>" + (link_to item.title, "/#{item.class.to_s.underscore}/#{item.title_sanitized}") + "</li>"
##    end
##    return str
##  end

#  protected

#    def build_params(options)
#      options[:field] ||= 'created_at'
#      options[:order] ||= 'desc'
#      options[:limit] ||= 5
#      hash = {
#        :models => options[:items],
#        :filter => { :field => options[:field], :way => options[:order]},
#        :pagination => { :page => options[:page] || 1, :per_page => options[:limit]},
#        :containers => {:website => [$current_website.id.to_s]},
#        :user => $current_website.creator,
#			  :permission => 'show',
#        :opti => options[:opti] ? options[:opti] : 'skip_pag_but_filter'
#      }
#      hash
#    end
#    
#  end
#   Liquid::Template.register_tag('items', Item)
end
