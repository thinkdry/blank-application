class Admin::AdministrationController < ApplicationController

	# Filter restricting the access to only superadministrator user
	before_filter :is_superadmin?

	def show
		
	end

end
