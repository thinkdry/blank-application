require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require File.expand_path(File.dirname(__FILE__) + '/../controllers/items_controller_spec_helper')
describe Admin::VideosController do
  controller_name 'admin/videos'
  #include ItemsControllerSpecHelper
  
  def object 
    Video
  end
  
  def valid_params
    {
       "associated_workspaces"=>["1"],
       "title"=>"hello",
       "description"=>"world",
       "video" => url_to_attachment_file('video.flv'),
       "keywords_field"=>[]
    }
  end
  
  def invalid_params
    {
       "associated_workspaces"=>["1"],
       "video" => url_to_attachment_file('empty_file.txt'),
       "description"=>"world",
       "title"=>"hello",
       "keywords_field"=>[]
    }
  end
  
end
