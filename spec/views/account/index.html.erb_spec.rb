require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/" do

  def page
    '/account/index.html.erb'
  end
  

  describe "latest elems" do
    fixtures :users, :pubmed_items, :pubmed_sources, :images
    
    before(:each) do
      assigns[:current_user]  = users(:luc)
          
      assigns[:latest_items]  = [images(:one)]
      assigns[:latest_ws]     = []
      assigns[:latest_users]  = []
      assigns[:latest_pubmed] = PubmedItem.all
      
      render page
    end

    describe "items" do
      
      it "should show latest items" do
        response.should have_tag('#items') do
          with_tag 'p', assigns[:latest_items].size
        end
      end
      
    end

    describe "publications" do
      
      it "should show latest pubmed items" do
        response.should have_tag('#publications') do
          with_tag 'p', assigns[:latest_pubmed].size
        end
      end
      
    end
  end

end