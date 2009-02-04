class ScaffoldMortarGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, 
                  :skip_migration => false, 
                  :force_plural => false

  attr_reader   :namespace,
                :model,
                :model_name,
                :attributes,
                :file_name,
                :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    
    super

    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end
    
    @model_name = get_model_name.camelize
    @controller_name = @name.pluralize

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
    
    @class_name = @model_name
    @file_name = @table_name.singularize
    @plural_name = @table_name
    @singular_name = @file_name
    
    # Hack to make namespaced form_for (doesn't consider multiple namespaces) 
    # -> e.g. form_for([:admin, @admin_jungles])
    # -> generated form with params[:jungle] not params[:admin_jungle]
    @namespace = @class_path
    @model = @file_name.split('_').pop
    
    @attributes = []
    if args.empty?
      @model_name.constantize.content_columns.each do |column|
        @attributes << Rails::Generator::GeneratedAttribute.new(column.name, column.type)
      end
    else
      @args.collect do |attribute|
        @attributes << Rails::Generator::GeneratedAttribute.new(*attribute.split(":"))
      end
    end
  end

  def manifest
    recorded_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller", "#{controller_class_name}Helper")

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/helpers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))
      m.directory(File.join('app/views/layouts', controller_class_path))
      m.directory(File.join('test/functional', controller_class_path))
      m.directory(File.join('public/stylesheets', class_path))

      for action in scaffold_views
        m.template(
          "view_#{action}.html.erb",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.erb")
        )
      end

      # Layout and stylesheet.
      m.template('layout.html.erb', File.join('app/views/layouts', controller_class_path, "#{controller_file_name}.html.erb"))
      m.template('style.css', File.join('public/stylesheets/', class_path, 'scaffold.css'))

      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )

      m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      m.template('helper.rb',          File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb"))
      
      m.route_resources controller_file_name

      # CM: Add this dependency when there are model arguments present
      if !@args.empty?
        m.class_collisions(model_name)
        m.dependency 'model', [model_name] + @args, :collision => :skip
      end
    end
    
    #
    # Post-install notes
    #
    action = File.basename($0) # grok the action from './script/generate' or whatever
    case action
    when "generate"
      puts "Ready to generate."
      puts ("-" * 70)
      puts "Once finished, don't forget to:"
      puts
      puts "If you are creating Admin UI by scaffolding Admin::Model_name"
      puts "- Cut"
      puts %(map.resources :#{get_model_name.downcase.pluralize})
      puts "- And paste as an 'Admin' namedspace route to resource."
      puts "- In config/routes.rb, insert routes like:"
      puts %(map.namespace :admin do |admin|)
      puts %(  admin.resources :#{get_model_name.downcase.pluralize})
      puts %(end)
    when "destroy"
      puts
      puts ("-" * 70)
      puts
      puts "Thanks for using scaffold_generator from Mortar Systems"
      puts
      puts "Don't forget to comment out the admin namedspace route for resource in routes.rb"
      puts "  (This was optional so it may not even be there)"
      puts "  # admin.resources :#{model_name.pluralize}"
      puts
      puts ("-" * 70)
      puts
    else
      puts "Didn't understand the action '#{action}' -- you might have missed the 'after running me' instructions."
    end

    #
    # Do the thing
    #
    recorded_session
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} scaffold NameSpace::ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--force-plural",
             "Forces the generation of a plural ModelName") { |v| options[:force_plural] = v }
    end

    def scaffold_views
      %w(index show new edit _form)
    end
    
    def get_model_name
      class_name.demodulize
    end
end
