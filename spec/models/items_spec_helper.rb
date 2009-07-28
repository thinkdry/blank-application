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

        it "can be rated" do
          @item.class.to_s.classify.constantize.reflect_on_association(:ratings).to_hash.should == rating_associations
        end

        it "can be commented" do
          @item.class.to_s.classify.constantize.reflect_on_association(:comments).to_hash.should == comment_associations
        end

        it "can have keywords through keywordings" do
          @item.class.to_s.classify.constantize.reflect_on_association(:keywordings).to_hash.should == keywording_associations
          @item.class.to_s.classify.constantize.reflect_on_association(:keywords).to_hash.should == keyword_associations
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
        describe "should have named scopes" do

          before(:each) do
            @item = item
          end

          it "Full Text Xapian Search" do
            @item.class.to_s.classify.constantize.full_text_with_xapian('hello').proxy_options.should == {:conditions => ["#{@item.class.to_s.pluralize.underscore}.id in (?)", []]}
          end

          it "Advance on Fields" do
            @item.class.to_s.classify.constantize.advanced_on_fields('').proxy_options.should == {:conditions => ''}
          end

          it "in_workspaces" do
            @item.class.to_s.classify.constantize.in_workspaces('1').proxy_options.should == {:select=>"DISTINCT *", :joins=>"LEFT JOIN items ON (items.itemable_type = '#{@item.class.to_s}' AND items.workspace_id IN ['1'])"}
          end

          it "filtering_with" do
            @item.class.to_s.classify.constantize.filtering_with('title','asc',2).proxy_options.should == {:limit=> 2, :order=>"#{@item.class.to_s.pluralize.underscore}.title asc"}
          end

        end
      end
    end
  end

  def workspace_item_associations
    {
      :macro => :has_many,
      :options => {:through=>:items, :extend=>[]},
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
      :options => {:dependent=>:delete_all, :as=>:itemable, :extend=>[]},
      :class_name => "Item"
    }
  end

  def rating_associations
    {
      :macro => :has_many,
      :options => {:dependent=>:destroy, :as=>:rateable, :extend=>[]},
      :class_name => "Rating"
    }
  end

  def comment_associations
    {
      :macro => :has_many,
      :options => {:conditions=>{:state=>"validated", :parent_id=>nil}, :as=>:commentable, :extend=>[], :order=>"created_at ASC"},
      :class_name => "Comment"
    }
  end

  def keyword_associations
    {
      :macro => :has_many,
      :options => {:through=>:keywordings, :extend=>[]},
      :class_name => "Keyword"
    }
  end

  def keywording_associations
    {
      :macro => :has_many,
      :options => {:dependent=>:delete_all, :as=>:keywordable, :extend=>[]},
      :class_name => "Keywording"
    }
  end

  def rating_associations
    {
      :macro => :has_many,
      :options => {:dependent=>:destroy, :as=>:rateable, :extend=>[]},
      :class_name => "Rating"
    }
  end
    
  def item_attributes
    { 
      :user => users(:luc),
      :title => 'My item',
      :description => 'Item description',
      :associated_workspaces => [workspaces(:private_for_luc).id]
    }
  end

  def item
    raise 'Item must be defined'
  end
end