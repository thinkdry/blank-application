class PubmedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	make_resourceful do
    actions :all
		belongs_to :workspace
    before :create, :update do
      @current_object.user_id=@current_user
    end
    after :create do 
      MiddleMan.worker(:pubmed_worker).async_retrieve_items()
    end
    before :index do
      @current_object=PubmedSource.new
    end
  end
end
