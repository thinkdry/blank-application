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
      # New object form displayed in index
      @current_object = PubmedSource.new
    end
    
    before :show do
      @pubmed_items = @current_object.pubmed_items.paginate(:page => params[:page], :per_page => 15)
    end
  end
  
  def current_objects
    # TODO: Get objects of current_user
    @current_objects ||= PubmedSource.paginate(
			:page => params[:page],
			:order => :created_at
		)
  end
end
