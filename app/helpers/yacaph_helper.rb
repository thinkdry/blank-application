module Yacaph
   def self.random_image
      @files ||= Dir.entries(RAILS_ROOT + '/public/images/captcha')[2..-1]
      @files[rand(@files.size)]
   end
end

module YacaphHelper
   
   def yacaph_image
      @yacaph_image ||= Yacaph::random_image
      image_tag('captcha/' + @yacaph_image, :height => '30px', :width => '140px')
   end
   
   def yacaph_input_text(label)
      @yacaph_image ||= Yacaph::random_image
      content_tag('label', label, :for => 'captcha') + text_field_tag(:captcha, '', :size => 10)
   end
   
   def yacaph_hidden_text
      @yacaph_image ||= Yacaph::random_image
      hidden_field_tag(:captcha_validation, @yacaph_image.gsub(/.png$/,''))
   end
   
   def yacaph_block(label = 'Insert Image Value:')
      content_tag('div', yacaph_hidden_text + yacaph_input_text(label) + yacaph_image, {:class => 'yacaph'})
   end
   
   def yacaph_validated?
      text3 = Yacaph::encrypt_string(params[:captcha] || '') == params[:captcha_validation]
   end
end