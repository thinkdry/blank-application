class ItemsController < ApplicationController
  
	def create
		if current_user.isSuperadmin?
			if @picture.save
				redirect_to superadministration_user_url(current_user)
				flash[:notice] = "Logo mis à jour"
			else
				render :nothing =>:true
			end
		else
			redirect_to "/"
			flash[:notice] = "Vous n'avez pas ce droit."
		end
	end
	
	
	
		
end