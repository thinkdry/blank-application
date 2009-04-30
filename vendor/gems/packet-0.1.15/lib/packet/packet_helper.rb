module Packet
  module ClassHelpers
    def metaclass; class << self; self; end; end

    def iattr_accessor *args
      metaclass.instance_eval do
        attr_accessor *args
        args.each do |attr|
          define_method("set_#{attr}") do |b_value|
            self.send("#{attr}=",b_value)
          end
        end
      end

      args.each do |attr|
        class_eval do
          define_method(attr) do
            self.class.send(attr)
          end
          define_method("#{attr}=") do |b_value|
            self.class.send("#{attr}=",b_value)
          end
        end
      end
    end # end of method iattr_accessor
    
    def inheritable_attribute *options_args
      option_hash = options_args.last
      args = options_args[0..-2]
      args.each {|attr| instance_variable_set(:"@#{attr}",option_hash[:default] || nil )}
      metaclass.instance_eval { attr_accessor *args }
      args.each do |attr|
        class_eval do
          define_method(attr) do
            self.class.send(attr)
          end
          define_method("#{attr}=") do |b_value|
            self.class.send("#{attr}=",b_value)
          end
        end
      end
    end
   module_function :metaclass,:iattr_accessor,:inheritable_attribute
  end # end of module ClassHelpers
end

