module ItemsSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :workspaces
      
      describe "as an item" do
        
        before(:each) do
         @item = item
        end

        it "should require user" do
         @item.attributes = item_attributes.except(:user)
         @item.should have(1).error_on(:user)
        end
        
        it "should require title" do
         @item.attributes = item_attributes.except(:title)
         @item.should have(1).error_on(:title)
        end

        it "should require description" do
         @item.attributes = item_attributes.except(:description)
         @item.should have(1).error_on(:description)
        end
        
        it "should accepts tags" do
          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
          @item.taggings.size.should == 2
        end
        
        it "should not record duplicated tags" do
          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2 tag1')
          @item.taggings.size.should == 2
        end
        
        it "should flat tags into 'tags' attribute" do
          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
          @item[:tags].should == 'tag1 tag2'
        end
        
        describe "string_tags method" do
          it "should return tags flatten (space separated)" do
            @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
            @item.string_tags.should == 'tag1 tag2'
          end
        end
        
      end
      
    end
  end
    
  def item_attributes
    { 
      :user => users(:luc),
      :title => 'My item',
      :description => 'Item description',
      :items => [ Item.new(:workspace => workspaces(:one)) ]
    }
  end
  
  def item
    raise 'Item must be defined'
  end
end