# TODO: Associate author (user) on creation

require 'pubmed'

class PubmedSourcesController < ApplicationController
  acts_as_ajax_validation
  
	make_resourceful do
    actions :all
		belongs_to :workspace
		
		before :show do
		  @rss = Pubmed.new(@current_object.url).rss
	  end
  end
  
end
