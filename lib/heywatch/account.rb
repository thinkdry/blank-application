module HeyWatch
  class Account < Base #:nodoc:
    def new_record?
      false
    end
    
    def update_attributes(attributes={})
      attributes.delete "account"
      attributes.keys.each do |k|
        attributes.merge!("user[#{k.to_s}]" => attributes[k])
        attributes.delete k
      end

      if Account.update(id, attributes)
        reload
        true
      end
    end

    def reload
      @attributes = Account.find.attributes
    end
    
    def id
      ""
    end
    
    def self.find(*args)
      new(HeyWatch::response(Browser::get(self.path, self.session).body))
    end
  end
end
