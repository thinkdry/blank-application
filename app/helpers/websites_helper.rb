module WebsitesHelper

#  def menu_generator(ul_class='', li_class='')
#    str = ""
#    @menus = @current_website.menus
#    str += "<ul class=#{ul_class}>"
#    @menus.roots.each do |root|
#      str +="<li>#{link_to root.name, (root.title_sanitized.to_s == '' ? '#' : '/' + root.title_sanitized) }"
#      str += root.children.blank? ? '</li>' : create_child(root) + '</li>'
#    end
#    str += '</ul>'
#  end

#  def create_child(object)
#    str = ""
#    str = '<ul id="' + object.name + '">'
#    object.children.each do |child|
#      str += "<li>#{link_to child.name, (child.title_sanitized.to_s == '' ? child.title_sanitized : '/' + child.title_sanitized)}"
#      str += child.children.blank? ? '</li>' : create_child(child) + '</li>'
#    end
#    str += '</ul>'
#  end
#  
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


end
