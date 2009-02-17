namespace :blank do
  desc "Create Basic Settings for BLANK"
  task(:pump => :environment) do
    ActiveRecord::Base.establish_connection
    # Drop All Pervious Roles & Permissions;
    sql =["TRUNCATE table roles;",
      "TRUNCATE table permissions;",
      "TRUNCATE table permissions_roles;",
      "TRUNCATE table elements"
    ]
    for i in sql
      query=<<-SQL
        #{i}
      SQL
      ActiveRecord::Base.connection.execute(query)
    end
    #Create New Basic System Roles
    p "Loading Roles......"
    @role=Role.create(:name =>'superadmin', :description=> 'SuperAdministration', :type_role =>'system')
    Role.create(:name =>'admin', :description=> 'Administration', :type_role =>'system')
    Role.create(:name =>'user', :description=> 'User', :type_role =>'system')
    Role.create(:name =>'ws_admin', :description=> 'Workspace Administrator', :type_role =>'workspace')
    Role.create(:name =>'moderator', :description=> 'Moderator of Workspace', :type_role =>'workspace')
    Role.create(:name =>'writer', :description=> 'Writer on Workspace', :type_role =>'workspace')
    Role.create(:name =>'reader', :description=> 'Reader on Workspace', :type_role =>'workspace')
    p "Done"
    p "Setting Up Users with Roles"
    @user=User.find_by_login('boss')
    if @user.nil?
      sql =[ "insert into users(id, login, firstname, lastname, email, address, company, phone, mobile, activity, nationality, edito, avatar_file_name, avatar_content_type, avatar_file_size, avatar_updated_at, crypted_password, salt, activation_code, activated_at, password_reset_code, system_role_id, created_at, updated_at, remember_token, remember_token_expires_at)values(1,'boss', 'Boss', 'Dupond', 'contact@thinkdry.com', '15 rue Leonard', 'ThinkDRY Technologies', '0112345678', '0612345678', 'Developer', 'France', '',null, null, null, null, 'a2c297302eb67e8f981a0f9bfae0e45e4d0e4317', '356a192b7913b04c54574d18c28d46e6395428ab', null, CURRENT_TIMESTAMP, null, #{@role.id}, CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, null, null);"
      ]
      for i in sql
        query=<<-SQL
        #{i}
        SQL
        ActiveRecord::Base.connection.execute(query)
      end
    else
      @user.system_role_id=@role.id
      @user.save
    end
    p "Done"
    p "Loading Permissions"
    (['users', 'workspaces']+ITEMS).each do |controller|
      ['new','edit','index','show', 'destroy'].each do |action|
        if controller=="users"
          if action=="show" || action=="index"
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
          else
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'system')
          end
        elsif controller=="workspaces"
          if action=="new" || action=="index"
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'system')
          else
            Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
          end
        else
          Permission.create(:name=>controller.singularize+'_'+action,  :type_permission =>'workspace')
        end
      end
    end
    p "Done"
    p "Assigning Permissions to Roles"
    @role_admin=Role.find_by_name("admin")
    @role_user=Role.find_by_name("user")
    @role_user.permissions << Permission.find_by_name("workspace_new")
    @role_ws=Role.find_by_name("ws_admin")
    @role_mod=Role.find_by_name("moderator")
    @role_red=Role.find_by_name("reader")
    @role_wri=Role.find_by_name("writer")
    # Permissions for admin
    Permission.find(:all).each do |p|
      @role_admin.permissions << p
    end
    # Permissions for ws_admin & moderator
    Permission.find(:all, :conditions => 'name LIKE "workspace%"').each do |p|
      @role_ws.permissions << p
      @role_mod.permissions << p if p.name!="workspace_destroy"
    end

    ITEMS.each do |item|
      ['new', 'edit', 'index', 'show'].each do |action|
        Permission.find(:all, :conditions =>{:name => item+'_'+action}).each do |p|
          if action=='new'  || action=='edit'
            @role_wri.permissions << p
          else
            @role_wri.permissions << p
            @role_red.permissions << p
          end
        end
      end
    end
    @role_red.permissions << Permission.find(:all, :conditions =>{:name => 'workspace_show'})
    @role_wri.permissions << Permission.find(:all, :conditions =>{:name => 'workspace_show'})
    p "Done"
    p "Creating Default Workspace"
    @user=User.find_by_login("boss")
    Workspace.create(:creator_id => @user.id, :description => "Private Workspace for Boss", :title=> "Private for Boss", :state => "private")
    p "Done"
    p "Loading Styles......"
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
    p "Done"
    p"------>>>Ready to Launch<<<------"
  end
end
#insert into roles(id, name, description, type_role, created_at, updated_at)values(1, 'superadmin', 'SuperAdministration', 'system' CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);",
#"insert into workspaces(id, creator_id, description, title, state, created_at, updated_at, ws_config_id)values(1, 1, 'Private Workspace for BOSS', 'Private for Boss', 'private', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP,1);"