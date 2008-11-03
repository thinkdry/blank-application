require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "GET /" do

  def page
    '/account/index.html.erb'
  end
  
  fixtures :users, :pubmed_items, :pubmed_sources, :images
  
  before(:each) do
    assigns[:current_user]  = users(:luc)
        
    assigns[:latest_items]  = [images(:one)]
    assigns[:latest_ws]     = []
    assigns[:latest_users]  = []
    assigns[:latest_pubmed] = PubmedItem.all
    
    render page
  end

end