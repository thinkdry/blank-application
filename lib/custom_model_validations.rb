module CustomModelValidations
  # reverse functionality of validates_format_of method
  # Validates whether the value of the specified attribute is not in format of the regular expression
  # provided.
  #
  #   class Person < ActiveRecord::Base
  #     validates_not_format_of :name, :with => /\A([0-9])\Z/i, :on => :create
  #   end
  #
  # A regular expression must be provided or else an exception will be raised.
  def validates_not_format_of(*attr_names)
    configuration = { :on => :save, :with => nil }
    configuration.update(attr_names.extract_options!)
    raise(ArgumentError, "A regular expression must be supplied as the :with option of the configuration hash") unless configuration[:with].is_a?(Regexp)

    validates_each(attr_names, configuration) do |record, attr_name, value|
      if value.to_s =~ configuration[:with]
        record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value)
      end
    end
  end

end
