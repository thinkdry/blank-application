class PubmedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	make_resourceful do
    actions :all
		belongs_to :workspace
    before :create, :update do
      @current_object.user_id=@current_user
    end
    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    before :index do
      @current_object=PubmedSource.new
			@current_objects=@current_objects.paginate(
				:page => params[:page],
				:order => :created_at,
				:per_page => 2
			)
    end
  end
end
