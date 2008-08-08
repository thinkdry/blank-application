module HeyWatch 
  # You can connect to the Hey!Watch service permanently
  #
  #  Base::establish_connection! :login => "login", :password => "password"
  #
  # You can access all the resources and manipulate the objects like in ActiveRecord
  #
  #  EncodedVideo.find(:all, :conditions => {:title => /bad video/i}).each do |v|
  #    v.destroy
  #  end
  #
  #  Format.create :name => "my new format", :video_codec => "mpeg4", ...
  #  
  #  f = Format.new
  #  f.container = "avi"
  #  f.audio_codec = "mp3"
  #  ...
  #  f.save
  #
  #  v = Video.find(15).update_attributes :title => "My edited title"
  #  puts v.title
  #
  #  Format.find_by_name("iPod 4:3")
  #  
  #  Format.find_all_by_name /ipod/i
  class Base
    attr_reader :attributes, :errors
    
    class << self
      def session=(session) #:nodoc:
        @session = session
      end

      def session #:nodoc:
        (@session || Base.session) rescue nil
      end
      
      # Establish the connection for all your session
      def establish_connection!(options={})
        Base.session = Browser::login(options[:login], options[:password])
      end

      def disconnect!
        Base.session = nil
      end
      
      def method_missing(m, *args) #:nodoc:
        if m.to_s =~ /find_by_(.*)/
          find(:first, :conditions => {$1.to_sym => args.first}) rescue nil
        elsif m.to_s =~ /find_all_by_(.*)/
          find :all, {:conditions => {$1.to_sym => args.first}}.merge(args[1]||{})
        else
          raise NoMethodError, "undefined method `#{m.to_s}' for #{self}"
        end
      end

      def path #:nodoc:
        return @path if @path
        "/"+self.to_s.split("::").last.
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
      
      # if the path of the resource is not standard, you can set it manually.
      #
      #   class Log < Base
      #      self.path = "/user_logs"
      #   end
      def path=(path) #:nodoc:
        @path = path
      end

      # Find objects
      # 
      # Arguments:
      #
      # * <tt>ID</tt> ID of the object
      # * <tt>:first</tt> retrieve the first result
      # * <tt>:all</tt> retrieve all the results
      # 
      # Options:
      #   
      # * <tt>:conditions</tt> {:fieldname => "keyword"} or {:fieldname => /[0-9]+/}
      # * <tt>:order</tt> to sort the result
      # * <tt>:limit</tt> limit the number of result to return
      # * <tt>:include</tt> fetch the object to include
      #
      #     Format.find(:all, :conditions => {:name => /mobile/i})
      #     Format.find(:all, :conditions => {:width => '<320'})
      #     Job.find(:all, :include => "encoded_video", :order => "created_at DESC", :limit => 3)
      #     Video.find :first
      #     Download.find(5)
      def find(*args)
        scope, options = args     
        options ||= {}
        case scope
          when :all   then find_every(options)
          when :first then find_every(options).first
          else             find_single(scope, options)
        end
      end
      
      private
      
      def find_every(options) #:nodoc:
        collection = []
        res = HeyWatch::response(Browser::get(path, session).body)
        return collection if res.empty?
        
        [res[res.keys.first]].flatten.each {|object| collection << new(object)}
        collection.find_with_options(options)
      end
      
      def find_single(arg, options) #:nodoc:
        new(HeyWatch::response(Browser::get(path+"/"+arg.to_s, session).body)).include_heywatch_object(options[:include])
      end
      
      public
        
      # Create the object
      #
      #   Download.create :url => "http://host.com/video.avi"
      def create(attributes={})
        new(HeyWatch::response(Browser::post(path, attributes, session).body))
      end
      
      # Update the object passing its ID
      #
      #   EncodedVideo.update 15, :title => "my title"
      def update(id, attributes={})
        Browser::put(path+"/"+id.to_s, attributes, session)
      end
      
      # Destroy the object passing its ID
      #
      #   Format.destroy 12
      def destroy(id)
        Browser::delete(path+"/"+id.to_s, session)
      end
      
      # Destroy all the objects
      #
      #   Video.destroy_all
      def destroy_all
        find(:all).each do |object|
          object.destroy
        end
      end

      # Count request
      #
      # Accept :conditions like in Base#find
      def count(field=nil, options={})
        find(:all, options).size
      end
    end
    
    # Instanciate a new object
    #
    #   Format.new :name => "test format", :sample_rate => 24000
    def initialize(attributes={})
      @attributes = attributes.underscore_keys!
      @attributes.type_cast!
    end

    def include_heywatch_object(objects=nil) #:nodoc:
      return self if objects.nil?
      objects = objects.to_s.split(",") if objects.is_a?(String) or objects.is_a?(Symbol)
      objects.each do |ob|
        begin
          self.instance_variable_set "@#{ob}", (self.send(ob) rescue nil)
          self.instance_eval "attr_reader #{ob.to_sym}"
        rescue
        end
      end
      self
    end

    # Save the object. 
    #
    # If the object doesn't exist, it will be created, otherwise updated.
    # If an error occurred, @errors will be filled. This method doesn't raise.
    def save
      begin
        save!
        true
      rescue => e
        @errors = e.to_s
        false
      end
    end
    
    # Save the current object
    #
    # Raise if an error occurred. Return self.
    def save!
      if new_record?
        self.class.create(@attributes)
      else
        update_attributes(@attributes)
      end
      self
    end

    def id #:nodoc:
      @attributes["id"].to_i
    end
    
    # Update the object with the given attributes
    #
    #   Video.find(10).update_attributes :title => "test title"
    def update_attributes(attributes={})
      if self.class.update(id, attributes)
        reload
        true
      end
    end
    
    # Destroy the object
    #
    #   Video.find(56).destroy
    def destroy
      self.class.destroy(id)
    end
    
    # Reload the current object
    #
    #   j = Job.find(5400)
    #   j.reload
    def reload
      unless new_record?
        @attributes = self.class.find(self.id).attributes
      end
      self
    end
    
    def new_record? #:nodoc:
      @attributes["id"].nil?
    end
    
    def method_missing(m, *args) #:nodoc:
      method_name = m.to_s
      case method_name[-1..-1]
      when '='
        @attributes[method_name[0..-2]] = *args.first
      when '?'
        @attributes[method_name[0..-2]]
      else
        if instance_variables.include?("@#{m.to_s}")
          eval("@#{m.to_s}")
        else
          if object_id = @attributes[m.to_s+"_id"] # belongs_to
            klass = HeyWatch::const_get(m.to_s.camelize)
            klass.session = self.class.session
            klass.find(object_id)
          else
            @attributes[m.to_s] rescue nil
          end
        end
      end
    end
  end

  Resources.each do |k| 
    HeyWatch.module_eval(%{class #{k.to_s.camelize} < Base; end})
  end
end
