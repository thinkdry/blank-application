require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Audio do
  include ItemsSpecHelper
  
  def item
    Audio.new
  end
end