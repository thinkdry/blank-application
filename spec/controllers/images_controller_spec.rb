require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../controllers/items_controller_spec_helper')
#require "#{RAILS_ROOT}/vendor/engines/acts_as_container/lib/url_helpers"
#require "#{RAILS_ROOT}/vendor/engines/acts_as_item/lib/url_helpers"
describe Admin::ImagesController do
  controller_name 'admin/images'
  include ItemsControllerSpecHelper
  
  def object 
    Image
  end
  
  def valid_params
    {
       "associated_workspaces"=>["1"],
       "title"=>"hello",
       "description"=>"world",
       "image" => url_to_attachment_file('image.png'),
       "keywords_field"=>[]
    }
  end
  
  def invalid_params
    {
       "associated_workspaces"=>["1"],
       "image" => url_to_attachment_file('empty_file.txt'),
       "description"=>"world",
       "title"=>"hello",
       "keywords_field"=>[]
    }
  end
  
end

