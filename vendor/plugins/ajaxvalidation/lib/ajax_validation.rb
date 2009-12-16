module AjaxValidation

  module Helpers
    def get_validation_url(object)
      "#{url_for(:action => :validate, :id => object.id)}"
    end
    
    # Used for generating errors on advanced FCK edior. In this case, the error is given to the user 
    # after a form submission. 
    def ajax_error_message_on(object, attribute)
      "<div id=\"errors_for_#{object.class.to_s}_#{attribute.to_s}\">
      #{error_message_on(object, attribute) if object.errors.on(attribute)}
      </div>"
		end
    
    #generate the hint div for form validation.
    def ajax_hint_message_on(object, attribute, message)
      #generating Id of type : hint_for_ItemClass_Attribute, hint_for_Article_title
      hint_message_id = 'hint_for_' + object.class.to_s + '_' + attribute.to_s
      field_id = object.class.to_s.underscore +  "_" + attribute.to_s.downcase
      
      hint_content = String.new
      
      hint_content = "<div id=\"#{hint_message_id}\" class=\"ajax_hint_message\" style=\"display:none\">
         <div class=\"hintSelector\"></div><div class=\"hintMessage\"><p>#{message}</p>"
      # if there are some errors on the fields, they are added on page construction
      # this happen when user click on submit without all the field validated. Input are red, and on focus
      # the system display hint message and error message in red.
      if object.errors.on(attribute)  
        hint_content += "<div class=\"formError\">#{error_message_on(object, attribute) }</div>"
      end
      
      hint_content += "</div></div>"
      
      return hint_content
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
      
      def field(field, *args, &block)
        @template.concat(labelize(field, *args) { @template.capture(&block) })
      end
      
      private
        
      def labelize(field, *args)
        
        object = @object || @object_name.to_s.classify.constantize.new
        
        # extracting option, giving the good specific option for Jquery ajax validation with unobtrusive 
        # Javascript. ClassName, validate and url are for this purpose. Ajax indicate if the field will 
        # have or not a validation throught ajax.
        options = args.extract_options!        
        options[:ajax] = true if options[:ajax].nil?
        options[:className] = object.class.to_s
        options[:validate] = field.to_s
        options[:url] = @template.get_validation_url(object)
        
        # If there is an error on the field, so we display the input with a special class to différenciate it
        # from other input fileds.
        if object.errors.on(field)
          options[:class] = "inputError"
        end
        
        label = options.delete(:label) || field.to_s.capitalize
        
        proc = Proc.new do
          obj = yield(field, *(args << options))
          # creation of the hint field.
					obj += @template.ajax_hint_message_on(object, field, options[:hint]) if options[:hint]
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
          @model_instance = params['id'] ? model_class.find(params['id']) : model_class.new

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
