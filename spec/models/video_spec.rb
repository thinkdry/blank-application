require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/items_spec_helper')

describe Video do
  include ItemsSpecHelper
  
  def item
    Video.new
  end
end