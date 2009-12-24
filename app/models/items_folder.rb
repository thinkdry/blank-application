class ItemsFolder < ActiveRecord::Base

  # Relation 1-N with the 'workspaces' table
  belongs_to :folder
  # Polymorphic relation with the items tables
  belongs_to :itemable, :polymorphic => true, :include => :user

  # Method retreiving the item object using the polymorphic relation
  def get_item #:nodoc:
    return self.itemable_type.classify.constantize.find(self.itemable_id)
  end

  # Method retrieving the title of the item object
  def title #:nodoc:
    return self.get_item.title
  end

  # Method retrieving the title of the description object
  def description #:nodoc:
    return self.get_item.description
  end

  # Scope retrieving the items list dependng of the workspace and the user
  named_scope :allowed_user_with_permission_in_folder, lambda { |user_id, permission_name, folder_ids|
    raise 'User required' unless user_id
    raise 'Permission name' unless permission_name
    if User.find(user_id).has_system_role('superadmin')
      { }
    else
      { :select => 'DISTINCT items_folders.*',
        :joins => #"LEFT JOIN workspaces ON items.workspace_id IN (#{workspace_ids.split(',')}) "+
        "LEFT JOIN users_containers ON users_containers.containerable_id IN (#{folder_ids.split(',')}) AND users_containers.containerable_type = 'Folder' AND users_containers.user_id = #{user_id.to_i} "+
          "LEFT JOIN permissions_roles ON permissions_roles.role_id = users_containers.role_id "+
          "LEFT JOIN permissions ON permissions_roles.permission_id = permissions.id",
        :conditions => "permissions.name LIKE '%#{permission_name.to_s}'" }
    end
  }


end
