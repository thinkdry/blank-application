class VideosController < ApplicationController
	
  acts_as_ajax_validation
	
	make_resourceful do
    actions :all
		belongs_to :workspace
  end	
  
end