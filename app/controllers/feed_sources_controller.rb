class FeedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	acts_as_ajax_validation
  acts_as_item do

		before :new do
			if params[:url]
				if (@feed=FeedNormalizer::FeedNormalizer.parse open(params[:url]), :force_parser => FeedNormalizer::SimpleRssParser)
					@current_object = FeedSource.new(
						:remote_id => @feed.id,
						:title => @feed.title,
						:description => @feed.description,
						:authors => @feed.authors.join(' ,'),
						:last_updated => @feed.last_updated,
						:link => @feed.url,
						:url => params[:url],
						:copyright => @feed.copyright,
						:generator => @feed.generator,
						:ttl => @feed.ttl,	
						#:image => @feed.image
						:state => 'copyright'
					)
					flash[:notice] = "Ce feed a retourné ces informations, validez-les pour y souscrire."
				else
					flash[:notice] = "Ce feed n'est pas valide."
					redirect_to 'feed_sources/what_to_to'
				end
			end
		end

    after :create do 
      # After addition of a source, import the RSS into DB.
      @current_object.import_latest_items
    end
    
    before :show do
      permit "consultation of current_object"
			@feed_items = @current_object.feed_items.paginate(:page => params[:page], :per_page => 15)
    end
		
  end

	def what_to_do
		
	end
  
  def check_feed
		daurl = params[:daurl][:value]
		if daurl.blank?
			flash[:notice] = "Entrer une valeur pour le Web feed."
			redirect_to '/feed_sources/what_to_do'
		elsif (@feed=FeedSource.find(:first, :conditions => { :url => daurl, :user_id => current_user.id }))
			flash[:notice] = "Déjà souscrit"
			redirect_to feed_item_path(@feed.id)
		else
			redirect_to "/feed_sources/new?url=#{daurl}"
		end
  end
	
end
