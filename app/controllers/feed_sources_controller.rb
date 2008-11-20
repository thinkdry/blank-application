class FeedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	make_resourceful do
    actions :all
    belongs_to :workspace

    before :create do
      @current_object.user = @current_user      
    end

    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end

    before :index do
      # New object form displayed in index
      @current_object = FeedSource.new
    end
    
    before :show do
      permit "consultation of current_object"
      @feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => 15)
    end
    
    before :edit, :update do
      permit "edition of current_object"
    end
  end
  
  def current_objects
    @current_objects ||= FeedSource.all(:conditions => "user_id = #{@current_user.id}").paginate(
			:page => params[:page],
			:order => :created_at
		)
  end
end
