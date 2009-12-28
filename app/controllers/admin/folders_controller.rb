class Admin::FoldersController < Admin::ApplicationController

	# Mixin setting the permission for that controller (see lib/acts_as_authorizable.rb for more)
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
