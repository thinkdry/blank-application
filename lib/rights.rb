module Blank
  module Rights
    
    def create_default_roles_if_empty
      if File.exist?("#{RAILS_ROOT}/test/fixtures/roles.yml")
        roles = YAML.load_file("#{RAILS_ROOT}/test/fixtures/roles.yml")
        roles.each do |k,v|
          aa_role = Role.find_by_name(k)
          unless aa_role
            role = Role.new(:name => v["name"], :description => v["description"])
            role.save!
            puts "Role #{v['name']} is created"
          end
        end
      end
    end
    
    def create_default_permissions_if_empty
      if File.exist?("#{RAILS_ROOT}/test/fixtures/permissions.yml")
        permissions = YAML.load_file("#{RAILS_ROOT}/test/fixtures/permissions.yml")
        permissions.each do |k,v|
          aa_permissions = Permission.find_by_name(k)
          unless aa_permissions
            permission = Permission.new(:name => v["name"], :description => v["description"])
            permission.save!
            puts "Permission #{v['name']} is created"
          end
        end
      end
    end
    
  end
end