module ActionView::Base::CompiledTemplates
  class ArticFormBuilder < LabelFormBuilder
    def default_template(object)
      %{
        <table>
          <tr>
            <td class="label"><label>#{object.label}</label></td>
            <td>#{object}</td>
          </tr>
        </table>
      }
    end
     
    def template_for_advanced_editor(object)
      %{
        <table>
          <tr>
            <td class="label"><label>#{object.label}</label></td>
            <td>#{@template.ajax_error_message_on(@object, object.method)}</td>
          </tr>
          <tr>
            <td colspan="2">#{object}</td>
          </tr>
        </table>
      }
    end
     
    def advanced_editor(field, *args)
      options = args.extract_options!
      options = options.merge(:ajax => false, :template => :template_for_advanced_editor)

      '<br' +
        text_area(field, options) +
        @template.advanced_editor_on(@object, field)
    end

    def tags_field(field, *args)
      text_field(field, *args)
    end
  end
end