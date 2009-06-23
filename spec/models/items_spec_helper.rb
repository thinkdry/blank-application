module ItemsSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users, :workspaces
      
      describe "as an Item" do
        
        before(:each) do
          @item = item
        end

        it "should belong to workspace'(s)" do
          @item.class.to_s.classify.constantize.reflect_on_association(:workspaces).to_hash.should == workspace_item_associations
        end

        it "should belong to user" do
          @item.class.to_s.classify.constantize.reflect_on_association(:user).to_hash.should == user_item_associations
        end

        it "should belong to items" do
          @item.class.to_s.classify.constantize.reflect_on_association(:items).to_hash.should == items_associations
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

        #        it "should require workspace" do
        #          @item.attributes = item_attributes.except(:associated_workspaces)
        #          @item.should have(1).error_on(:associated_workspaces)
        #        end
        
        #        it "should accepts tags" do
        #          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
        #          @item.taggings.size.should == 2
        #        end
        #
        #        it "should not record duplicated tags" do
        #          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2 tag1')
        #          @item.taggings.size.should == 2
        #        end
        #
        #        it "should flat tags into 'tags' attribute" do
        #          @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
        #          @item[:tags].should == 'tag1 tag2'
        #        end
        #
        #        describe "string_tags method" do
        #          it "should return tags flatten (space separated)" do
        #            @item.attributes = item_attributes.merge(:string_tags => 'tag1 tag2')
        #            @item.string_tags.should == 'tag1 tag2'
        #          end
        #        end
        
      end
      
    end
  end

  def workspace_item_associations
    {
      :macro => :has_many,
      :options => {:through=>:items, :source=>:workspace, :group=>nil, :foreign_key=>"workspace_id", :limit=>nil, :extend=>[], :class_name=>"Workspace", :offset=>nil, :order=>nil, :conditions=>nil},
      :class_name => "Workspace"
    }
  end

  def user_item_associations
    {
      :macro => :belongs_to,
      :options => {},
      :class_name => "User"
    }
  end

  def items_associations
    {
      :macro => :has_many,
      :options => {:dependent=>:destroy, :conditions=>nil, :as=>:itemable, :extend=>[], :class_name=>"Item", :order=>nil},
      :class_name => "Item"
    }
  end
    
  def item_attributes
    { 
      :user => users(:luc),
      :title => 'My item',
      :description => 'Item description',
      :associated_workspaces => [workspaces(:one).id]
    }
  end

  def item
    raise 'Item must be defined'
  end
end