# This FormBuilder will define a generic form for the Bank application,
# setting the special case of the FCKeditor field,
# and also managing the AJAX validation by adding the <div> necessary for that plugin.
#
module ActionView::Base::CompiledTemplates
  class BlankFormBuilder < LabelFormBuilder
    def default_template(object)
      %{
        <label>#{object.label}</label>
        <div class="formElement">#{object}</div>
      }
    end
     
    def template_for_advanced_editor(object)
      %{
          <label>#{object.label}</label>
          <div class="formElement">#{@template.ajax_error_message_on(@object, object.method)}</div>
          <div class="advancedEditor">#{object}</div>
      }
    end
     
   def advanced_editor(field, *args)
      options = args.extract_options!
      options = options.merge(:ajax => false, :template => :template_for_advanced_editor)
      width = options[:width] || '730px'
      height = options[:height] || '350px'

      text_area(field, options) +
      @template.advanced_editor_on(@object, field, width, height)
    end
      
        text_area(field, options) +
        @template.advanced_editor_on(@object, field)
    end

    def tags_field(field, *args)
      text_field(field, *args)
    end
  end
end