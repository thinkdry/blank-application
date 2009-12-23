namespace :blank do

  desc "Install Blank Application"
	task :install => :environment do
    p "Installing required gems"
    Rake::Task['gems:install'].invoke
    p "Creating Database"
		Rake::Task['db:create'].invoke
    p "Migrating"
		Rake::Task['db:migrate'].invoke
    p "Setting Up Default Settings"
		Rake::Task['blank:pump'].invoke
    p "Setting Other Settings"
    Rake::Task['blank:init'].invoke
    p "Starting Delayed_Job"
    system("ruby script/delayed_job start")
    p "Creating Cron Schedules"
    system("whenever --update-crontab blank -s environment=#{RAILS_ENV}")
    Rake::Task['blank:xapian_rebuild'].invoke
    p "Installed Blank Application Sucessfully."
	end

	desc "Initializing Blank Engine"
	task :init => :environment do
		system("rake captcha:generate COUNT=10")
		#Rake::Task['captcha:generate'].invoke
	end

	desc "Initializing Blank Engine"
	task :update => :environment do
		Rake::Task['gems:install'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['blank:xapian_rebuild'].invoke
	end

	desc "Building Xapian indexes"
	task :xapian_rebuild => :environment do
		p "Building Xapian indexes"
		system("rake xapian:rebuild_index models='#{ITEMS.map{ |e| e.camelize }.join(' ')} User Workspace' RAILS_ENV=#{RAILS_ENV}")
		#Rake::Task['xapian:rebuild_index'].invoke("models=\"#{ITEMS.map{ |e| e.camelize }.join(' ')} User Workspace\"")
		p "Done"
	end

  desc "Create Basic Settings for BLANK"
  task(:pump => :environment) do
    Rake::Task['blank:drop_rights'].invoke
    Rake::Task['blank:create_permissions'].invoke
    Rake::Task['blank:create_roles'].invoke
    Rake::Task['blank:create_users'].invoke
    Rake::Task['blank:create_workspaces'].invoke
    Rake::Task['blank:css'].invoke
    p "Populate database with test data y/n"
    if STDIN.gets.chomp == 'y'
      Rake::Task['db:populate'].invoke
    end
  end

	desc "From drop to pump"
	task(:pumper => :environment) do
		Rake::Task['db:drop'].invoke
		Rake::Task['db:create'].invoke
		Rake::Task['db:migrate'].invoke
		Rake::Task['blank:pump'].invoke
	end

	### Pump subtasks

  desc "Drop Roles & Permissions"
  task(:drop_rights => :environment) do
    ActiveRecord::Base.establish_connection
    # Drop All Pervious Roles & Permissions;
    sql =["TRUNCATE table roles;",
      "TRUNCATE table permissions;",
      "TRUNCATE table permissions_roles;",
      "TRUNCATE table elements;"
    ]
    for i in sql
      query=<<-SQL
        #{i}
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
  end

  desc "Loading Roles"
  task(:create_roles => :environment) do
    p "Loading Roles ..."
    Role.create(:name =>'superadmin', :description=> 'SuperAdministration', :type_role =>'system')
    Role.create(:name =>'admin', :description=> 'Administration', :type_role =>'system')
    Role.create(:name =>'user', :description=> 'User', :type_role =>'system')
    Role.create(:name =>'ws_admin', :description=> 'Workspace Administrator', :type_role =>'workspace')
    Role.create(:name =>'moderator', :description=> 'Moderator of Workspace', :type_role =>'workspace')
    Role.create(:name =>'writer', :description=> 'Writer on Workspace', :type_role =>'workspace')
    Role.create(:name =>'reader', :description=> 'Reader on Workspace', :type_role =>'workspace')
    p "Done"
    p "Assigning Permissions to Roles ..."

    @role_admin=Role.find_by_name("admin")
    @role_user=Role.find_by_name("user")
    @role_ws=Role.find_by_name("ws_admin")
    @role_mod=Role.find_by_name("moderator")
    @role_red=Role.find_by_name("reader")
    @role_wri=Role.find_by_name("writer")
    # Permissions for SUPERADMIN
    # don't care, checked directly with the role
    # Permissions for ADMIN
    Permission.find(:all).each do |p|
      @role_admin.permissions << p
    end
    # Permissions for USER ROLES
    @role_user.permissions << Permission.find_by_name("workspace_new")
    # Permissions for WORKSPACE ROLES
    Permission.find(:all, :conditions => 'name LIKE "workspace%" AND type_permission="workspace"').each do |p|
      @role_ws.permissions << p
      @role_mod.permissions << p if p.name!="workspace_destroy"
    end
    ITEMS.each do |item|
      ['new', 'edit', 'index', 'show', 'destroy','comment','rate'].each do |action|
        Permission.find(:all, :conditions =>{:name => item+'_'+action}).each do |p|
          if action=='new'  || action=='edit'
            @role_ws.permissions << p
            @role_mod.permissions << p
            @role_wri.permissions << p
          elsif action=='destroy'
            @role_ws.permissions << p
            @role_mod.permissions << p
          else
            @role_ws.permissions << p
            @role_mod.permissions << p
            @role_wri.permissions << p
            @role_red.permissions << p
          end
        end
      end
    end
    @role_red.permissions << Permission.find(:all, :conditions =>{:name => 'workspace_show'})
    @role_wri.permissions << Permission.find(:all, :conditions =>{:name => 'workspace_show'})
    @admin_ws = Permission.create(:name => 'workspace_administrate', :type_permission => 'workspace') unless Permission.exists?(:name => 'workspace_administrate', :type_permission => 'workspace')
    if @admin_ws
      @role_ws.permissions << @admin_ws
      @role_mod.permissions << @admin_ws
    end
    p "Done"
  end

  desc "Load Permissions"
  task(:create_permissions => :environment) do
    p "Loading Permissions ..."
		Permission.delete_all
    (['users', 'workspaces']+ITEMS).each do |controller|
      ['new','edit', 'show', 'destroy'].each do |action|
        if controller=="users"
          if action=="show" || action=="index"
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
          else
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'system')
          end
        elsif controller=="workspaces"
          if action=="new" || action=="index"
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'system') unless Permission.exists?(:name=>controller.singularize+'_'+action,  :type_permission =>'system')
          else
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace') unless Permission.exists?(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
          end
        else
          Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace') unless Permission.exists?(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
        end
      end
    end
    ITEMS.each do |controller|
      ['comment', 'rate', 'tag'].each do |action|
        Permission.create(:name => controller.singularize+'_'+action, :type_permission => 'workspace') unless Permission.exists?(:name => controller.singularize+'_'+action, :type_permission => 'workspace')
      end
    end
		Permission.create(:name => 'user_configure', :type_permission => 'system')
		Permission.create(:name => 'workspace_administrate', :type_permission => 'workspace')
		Permission.create(:name => 'workspace_contacts_management', :type_permission => 'workspace')
    p "Done"
  end

  desc "Load Users"
  task(:create_users => :environment) do
    @superadmin = Role.find_by_name('superadmin')
    @admin = Role.find_by_name('admin')
    @user = Role.find_by_name('user')
    @sauser = User.first
    if @sauser.nil?
      sql =[ "insert into users(id, login, firstname, lastname, email, address, company, phone, mobile, activity, nationality, edito, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, crypted_password, salt, activation_code, activated_at, password_reset_code, system_role_id, created_at, updated_at, remember_token, remember_token_expires_at)values(1,'boss', 'Boss', 'Dupond', 'contact@thinkdry.com', '15 rue Leonard', 'ThinkDRY Technologies', '0112345678', '0612345678', 'Developer', 'France', '',null, null, null, null, '', '', null, CURRENT_TIMESTAMP, null, #{@superadmin.id}, CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, null, null);"
      ]
      for i in sql
        query=<<-SQL
        #{i}
        SQL
        ActiveRecord::Base.connection.execute(query)
        p "Enter superadmin username(Press Enter for default username) :- "
        @suser = STDIN.gets.chomp
        p  "Enter superadmin password(Press Enter for default password) :- "
        @spwd = STDIN.gets.chomp
        if @suser.blank?
          @suser = 'boss'
        end
        if @spwd.blank?
          @spwd = 'monkey'
        end
        @sa_user = User.find_by_login('boss')
        @sa_user.firstname = @suser
        @sa_user.login = @suser
        @sa_user.password = @spwd
        @sa_user.password_confirmation = @spwd
        @sa_user.save(false)
        p "Setting Username = #{@suser} & Password = #{@spwd}"
      end
    else
      @sauser.system_role_id = @superadmin.id
      @sauser.save
    end
    p "Setting Up 'quentin' as User"
    @auser=User.find_by_login('quentin')
    if @auser.nil?
      sql =[ "insert into users(id, login, firstname, lastname, email, address, company, phone, mobile, activity, nationality, edito, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, crypted_password, salt, activation_code, activated_at, password_reset_code, system_role_id, created_at, updated_at, remember_token, remember_token_expires_at)values(2,'quentin', 'Quentin', 'Dupond', 'contact@thinkdry.com', '15 rue Leonard', 'ThinkDRY Technologies', '0112345678', '0612345678', 'Developer', 'France', '',null, null, null, null, 'a2c297302eb67e8f981a0f9bfae0e45e4d0e4317', '356a192b7913b04c54574d18c28d46e6395428ab', null, CURRENT_TIMESTAMP, null, #{@user.id}, CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, null, null);"
      ]
      for i in sql
        query=<<-SQL
        #{i}
        SQL
        ActiveRecord::Base.connection.execute(query)
      end
    else
      @auser.system_role_id=@user.id
      @auser.save
    end
    p "Done"
  end

  desc "Default Workspace Creation"
  task(:create_workspaces => :environment) do
    p "Loading Default Configuration for Workspace"
    if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
      @default_conf= YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
    else
      @default_conf= YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
    end
    p "Done"
    p "Creating Default Workspace"
    @superadmin = User.first
    if Workspace.find_by_creator_id_and_state(@superadmin.id, "private").blank?
      @ws=Workspace.create(:creator_id => @superadmin.id, :description => "Archive for #{@superadmin.login}", :title=> "Archive for #{@superadmin.login}", :state => "private", :available_items => @default_conf['sa_items'].to_a)
      @ws.users_containers.create(:role_id => Role.find_by_name("ws_admin").id, :user_id => @superadmin.id)
    end


    @user=User.find_by_login("quentin")
    if Workspace.find_by_creator_id_and_state(@user.id, "private").blank?
      @ws=Workspace.create(:creator_id => @user.id, :description => "Archive for Quentin", :title=> "Archive for Quentin", :state => "private", :available_items => @default_conf['sa_items'].to_a)
      @ws.users_containers.create(:role_id => Role.find_by_name("ws_admin").id, :user_id => @user.id )
    end

    p "Done"
  end

  desc "Default Styles"
  task(:css => :environment) do
    p "Loading Styles if blank ..."
    if Element.find(:all).blank?
      Element.create(:name => "header", :bgcolor =>"#FFFFFF", :template => "current")
      Element.create(:name => "body", :bgcolor => "#FFFFFF", :template => "current")
      Element.create(:name => "footer", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "top", :bgcolor => "#D86C27", :template => "current")
      Element.create(:name => "search", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "ws", :bgcolor => "#FF9933", :template => "current")
      Element.create(:name => "border", :bgcolor => "#D86C27", :template => "current")
      Element.create(:name => "accordion", :bgcolor => "#666666", :template => "current")
      Element.create(:name => "links", :bgcolor => "#6C320C", :template => "current")
      Element.create(:name => "clicked", :bgcolor => "#FF9933", :template => "current")
    end
    p "Done"
  end

  desc "To Recreate generic_items view"
  task :recreate_generic_items_view => :environment do
    puts "Recreating generic_items view...."
    subqueries = Array.new
    ITEMS.map{ |item| item.to_sym }.each do |model|
      table_name = model.to_s.pluralize
      model_name = model.to_s.classify
      subqueries << %{
        SELECT
          '#{model_name}' as item_type,
          id,
          user_id,
          ( SELECT CONCAT_WS(' ', users.login, users.firstname, users.lastname)
            FROM users
            WHERE users.id = #{table_name}.user_id
          ) as user_name,
          title,
          description,
          created_at,
          updated_at,
          comments_number,
          rates_average
        FROM #{table_name} }
    end
    ActiveRecord::Base.connection.execute("CREATE OR REPLACE VIEW generic_items AS #{subqueries.join(' UNION ALL ')}".tr_s(" \n", ' '))
  end

  desc "To generate sha1_id value in contacts_workspace table"
  task(:generate_sha1_id => :environment) do
    puts "------> Generatin sha1_id value"
    for c_w in ContactsWorkspace.find(:all, :conditions => ["sha1_id <=> NULL OR sha1_id = ''"])
      c_w.save
    end
  end
  desc "To create default sa_config.yml"
  task(:create_sa_config => :environment) do
    puts "------> creating sa config"
    default_config = YAML.load_file("#{RAILS_ROOT}/config/customs/default_config.yml")
    if File.exist?("#{RAILS_ROOT}/config/customs/sa_config.yml")
      sa_config = YAML.load_file("#{RAILS_ROOT}/config/customs/sa_config.yml")
      non_exists = default_config.map{|k, v| k } - sa_config.map{|k, v| k }
      non_exists.each do |key|
        sa_config.merge!(key => default_config[key])
      end
      un_used = sa_config.map{|k, v| k } - default_config.map{|k, v| k }
      un_used.each do |key|
        sa_config.delete(key)
      end
      new_sa_config = File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
      new_sa_config.syswrite(sa_config.to_yaml)
    else
      new_sa_config = File.new("#{RAILS_ROOT}/config/customs/sa_config.yml", "w+")
      new_sa_config.syswrite(default_config.to_yaml)
    end
    puts "------> created sa config"
  end

  desc "To delete dupicate records from join tables"
  task(:delete_duplicates_in_join_tables => :environment) do
    #      model_name = "ItemsWorkspace"
    #      fields_to_check = ['itemable_type', 'itemable_id', 'workspace_id']
    model_fields = {'ItemsWorkspace' => ['itemable_type', 'itemable_id', 'workspace_id']} #, 'UsersWorkspace' => ['user_id', 'workspace_id']}
    model_fields.each do |model_name, fields_to_check|
      model_name.classify.constantize.all.each do |item_w|
        cond = {}
        fields_to_check.each{|f| cond.merge!({f.to_sym => item_w.send(f.to_sym)})}
        tmp = model_name.classify.constantize.find(:all, :conditions => cond)
        if tmp.length > 1
          tmp.delete_if{|i| i.id == item_w.id}.each{|it| it.delete}
        end
      end
    end
  end

  namespace :maintaining do

		desc "To Reencode videos"
		task(:video_reencode => :environment) do
			@videos = Video.find(:all, :conditions =>["state = 'uploaded' OR state = 'encoding_error' OR state = 'error'"])
			for video in @videos
				puts "---->Reencoding started for video #{video.id}"
        Delayed::Job.enqueue(EncodingJob.new({:type=>"video", :id => video.id, :enc=>"flv"}))
			end
		end

		desc "To Reencode audios"
		task(:audio_reencode => :environment) do
			@audios = Audio.find(:all, :conditions =>["state = 'uploaded' OR state = 'encoding_error' OR state = 'error'"])
			for audio in @audios
				puts "---->Reencoding started for audio #{audio.id}"
        Delayed::Job.enqueue(EncodingJob.new({:type=>"audio", :id => audio.id, :enc=>"flv"}))
      end

      desc "To set items default values (comments number, ...)"
      task :default_values_for_items => :environment do
        #['article', 'image', 'cms_file', 'video', 'audio', 'publication', 'feed_source', 'bookmark','newsletter','group'].each do |item|
        ITEMS.each do |item|
          puts "Updating for #{item}"
          (item.classify.constantize).all.each do |e|
            puts "Updating #{item} with id = #{e.id}"
            if !e.workspaces.blank?
              if e.comments_number.nil?
                e.comments_number = 0
              end
              if e.rates_average.nil?
                e.rates_average = 0
              end
              if e.viewed_number.nil?
                e.viewed_number = 0
              end
              if e.save(false)
                puts "Updated record #{e.id}"
              else
                puts "Updating Record with id #{e.id} failed"
                puts e.errors.inspect
              end
            else
              puts "Destroying record #{e.id} of type #{item}"
              e.destroy
              puts "Destroyed"
            end
          end
        end
      end
    end
  end

  namespace :cache do
    desc "Clears javascripts/cache and stylesheets/cache"
    task :clear => :environment do
      FileUtils.rm(Dir['public/javascripts/cache/[^.]*'])
      FileUtils.rm(Dir['public/stylesheets/cache/[^.]*'])
    end
  end
end
