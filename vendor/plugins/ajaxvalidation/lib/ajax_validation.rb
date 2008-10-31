module AjaxValidation

  module Helpers
    def ajax_validation(object, attribute)
      "ajax_validation('#{object.class.to_s}', '#{attribute.to_s}', this.value, '#{url_for(:action => :validate)}')"
    end
  
    def ajax_error_message_on(object, attribute)
      "<span id=\"errors_for_#{object.class.to_s}_#{attribute.to_s}\">
        #{error_message_on(object, attribute) if object.errors.on(attribute)}
      </span>"
    end
    
    def ajax_hint_message_on(object, attribute, message)
      hint_message_id = 'hint_for_' + object.class.to_s + '_' + attribute.to_s
      field_id = object.class.to_s.underscore +  "_" + attribute.to_s.downcase
      
      javascript_tag("
        Event.observe('#{field_id}', 'focus', function() { #{ update_page { |p| p[hint_message_id].show } } })
        Event.observe('#{field_id}', 'blur',  function() { #{ update_page { |p| p[hint_message_id].hide } } })
      ") +
      "<div id=\"#{hint_message_id}\" class=\"ajax_hint_message\" style=\"display:none\">
        #{message}
      </div>"
    end
  end  
  
  module FormBuilders
    class LabelFormBuilder < ActionView::Helpers::FormBuilder
      helpers = field_helpers +
                %w{date_select datetime_select time_select} +
                %w{collection_select select country_select time_zone_select} -
                %w{hidden_field label fields_for} # Don't decorate these

      helpers.each do |name|
        define_method(name) do |field, *args|
          labelize(field, *args) { |*args| super(*args) }
        end
      end
      
      def default_template(object)
        @template.content_tag(:p,
          @template.label(object.object_name, object.method, object.label) + '<br />' +
          object
        )
      end
      
      def field(field, *args, &block)
        @template.concat(labelize(field, *args) { @template.capture(&block) }, block.binding)
      end
      
      private
      def labelize(field, *args)
        object = @object || @object_name.to_s.classify.constantize.new

        options = args.extract_options!        
        options[:ajax] = true if options[:ajax].nil?
        options[:onblur] = @template.ajax_validation(object, field) if options[:ajax]
        
        label = options.delete(:label) || field.to_s.capitalize

        proc = Proc.new do
          obj = yield(field, *(args << options))
          obj += @template.ajax_error_message_on(object, field) if options[:ajax]
          obj.instance_exec do
            @label = label.to_s
            @object = object
            @object_name = object.class.to_s.downcase
            @method = field.to_s
            def object
              @object
            end
            def instance
              @object
            end
            def label
              @label
            end
            def object_name
              @object_name
            end
            def method
              @method
            end
          end
          obj
        end
        
        template_method = options.delete(:template) || 'default_template' 
        self.send(template_method, proc.call)
      end
    end 
  end
  
  module ControllerMethods
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_ajax_validation
        include AjaxValidation::ControllerMethods::InstanceMethods
      end
    end
    
    module InstanceMethods
      def validate
          model_class = params['model'].classify.constantize
          @model_instance = model_class.new

          @model_instance.send("#{params['attribute']}=", params['value'])
          @model_instance.valid?
          render :inline => "<%= error_message_on(@model_instance, params['attribute']) %>"
      end
    end  
  end
  
  module ModelMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def validates_presence_of *args
        @@required_fields ||= Array.new
        @@required_fields |= args.select { |e| e.class == Symbol }
        super(*args)
      end
      
      def required_fields
        @@required_fields ||= Array.new
      end
        
    end
  end
  
end
