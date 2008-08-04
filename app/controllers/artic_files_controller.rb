class ArticFilesController < ApplicationController
	
  acts_as_ajax_validation
	
	make_resourceful do
    actions :all
		belongs_to :workspace
    
    before :create, :new, :index do
  	  permit "member of workspace" if @workspace
  	end
  	
  	before :edit, :update, :delete do
  	  debugger
  	  permit "author of artic_file"
	  end

  end
  
end