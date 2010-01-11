module WebsitesHelper
#  include GoogleTranslate

#  def translate_text(content_text)
#    default_lang = 'fr'
#    # current_lang = LanguageDetect.detect(content_text)
#    if session[:sl] != default_lang && content_text && !content_text.blank?
#      translator = Translator.new(default_lang, session[:sl].split('-').first)
#      translated_text = translator.translate(content_text)
#    end
#    logger.error "helloooo"
#    translated_text ||= content_text
#    return translated_text
#  rescue InvalidLanguage => e
#    logger.error e.inspect
#    flash[:error] = "Invalid language"
#    return content_text
#  rescue GoogleUnavailable => e
#    logger.error e.inspect
#    flash[:error] = "Translator not available, try later"
#    return content_text
#  rescue GoogleException => e
#    logger.error e.inspect
#    flash[:error] = "Translator error, try later"
#    return content_text
#  rescue UnreliableDetection => e
#    logger.error e.inspect
#    flash[:error] = "Translator not available, try later"
#    return content_text
#  rescue NoGivenString => e
#    # already managed normally
#    logger.error e.inspect
#  end

  def menu_generator(css_class='')
    str = ""
    @website = Website.find(session[:website_id])
    @menus = @website.menus
    str += "<ul class=#{css_class}>"
    @menus.roots.each do |root|
      str +="<li>#{link_to root.name, (root.url == '#' ? root.url : '/' + root.url) }"
      str += root.children.blank? ? '</li>' : create_child(root) + '</li>'
    end
    str += '</ul>'
  end

  def create_child(object)
    str = ""
    str = '<ul>'
    object.children.each do |child|
      str += "<li>#{link_to child.name, (child.url == '#' ? child.url : '/' + child.url)}"
      str += child.children.blank? ? '</li>' : create_child(child) + '</li>'
    end
    str += '</ul>'
  end

end
