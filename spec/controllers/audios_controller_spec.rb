require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
#require File.expand_path(File.dirname(__FILE__) + '/../controllers/items_controller_spec_helper')
describe Admin::AudiosController do
  #include ItemsControllerSpecHelper
  controller_name 'admin/audios'
  def object 
    Audio
  end
  
  def valid_params
    {
       "associated_workspaces"=>["1"],
       "title"=>"hello",
       "description"=>"world",
       "audio" => url_to_attachment_file('audio.mp3'),
       "keywords_field"=>[]
    }
  end
  
  def invalid_params
    {
       "associated_workspaces"=>["1"],
       "audio" => url_to_attachment_file('empty_file.txt'),
       "description"=>"world",
       "title"=>"hello",
       "keywords_field"=>[]
    }
  end
  
end
