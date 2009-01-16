class VideosController < ApplicationController	
  acts_as_ajax_validation
	acts_as_item
	
	after :create do

  end
	
end