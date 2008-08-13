class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item
	
	def progression
		if session[:uploading] < 101
			return "Envoi du fichier sur HeyWatch ("+session[:uploading]+" %)"
		elsif session[:encoding] < 101
			return "Encodage du fichier ("+session[:encoding]+" %)"
		elsif session[:downloading] < 101
			return "Téléchargement du fichier encodé ("+session[:downloading]+" %)"
    else
			redirect_to object(@current_object.id)
		end
	end
	
end