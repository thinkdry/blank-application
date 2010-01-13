# This FormBuilder will define a generic form for the Bank application,
# setting the special case of the FCKeditor field,
# and also managing the AJAX validation by adding the <div> necessary for that plugin.
#
module ActionView::Base::CompiledTemplates
  class BlankFormBuilder < LabelFormBuilder
    def default_template(object)
      template = String.new
      
      if object.label != " "
        template += "<label>#{object.label}</label>"
      end
      
      template += "<div class=\"formElement\">#{object}</div>"

      return template
    end
     
    def template_for_advanced_editor(object)   
      code_for_fck = ''
      code_for_fck += '<div class="errorForAdvancedEditor">' + @template.ajax_error_message_on(@object, object.method) + '</div>'
      if CONTAINERS.include?(@object.class.to_s.underscore)
        code_for_fck += '<input type="hidden" value="/admin/ajax_container_save/' + @object.class.to_s.underscore.pluralize + '/" id="ajax_save_url"/>'
      else
        code_for_fck += '<input type="hidden" value="/admin/ajax_item_save/' + @object.class.to_s.underscore.pluralize + '/" id="ajax_save_url"/>'
      end
      code_for_fck += '<input type="hidden" value="' + @object.id.to_s + '" id="item_id"/>'
      code_for_fck += '<div class="advancedEditor">' + object + '</div>'    
      %{#{code_for_fck}}
    end
     
		def advanced_editor(field, *args)
      options = args.extract_options!
      options = options.merge(:ajax => false, :template => :template_for_advanced_editor, :id => 'ckInstance')
      text_area(field, options) +
      @template.advanced_editor_on(@object, field)
    end
      
    def tags_field(field, *args)
      text_field(field, *args)
    end
  end
end
