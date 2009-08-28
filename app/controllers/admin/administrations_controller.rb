class Admin::AdministrationController < ApplicationController

	before_filter :is_superadmin?

	def show
		
	end

end
