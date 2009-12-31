class Admin::<%= controller_class_name %>Controller < ApplicationController

  acts_as_authorizable(
		:actions_permissions_links => {
      'new' => 'new',
      'create' => 'new',
      'edit' => 'edit',
      'update' => 'edit',
      'show' => 'show',
      'rate' => 'rate',
      'add_comment' => 'comment',
      'destroy' => 'destroy',
      'add_new_user' => 'edit'
    },
		:skip_logging_actions => [])

  acts_as_container
	
end
