module ItemsSpecHelper
  def self.included(base)
    base.module_eval do
      #include AuthorizableSpecHelper
      fixtures :users, :workspaces

      def object
        item
      end

      describe "as an Item" do

        before(:each) do
          @object = item
          @object_name = item.class.to_s.underscore
          @object_instance = @object_name.classify.constantize
        end
        
        CONTAINERS.each do |container|
          it "should belong to #{container}'(s)" do
            @object_instance.reflect_on_association(container.pluralize.to_sym).to_hash.should == container_item_associations(container)
          end
          
          it "should belong to items #{container}" do
            @object_instance.reflect_on_association("items_#{container.pluralize}".to_sym).to_hash.should == items_container_associations(container)
          end
        end

        it "should belong to user" do
          @object_instance.reflect_on_association(:user).to_hash.should == user_item_associations
        end
        
        it "can be rated" do
          @object_instance.reflect_on_association(:ratings).to_hash.should == rating_associations
        end

        it "can be commented" do
          @object_instance.reflect_on_association(:comments).to_hash.should == comment_associations
        end

        it "can have keywords through keywordings" do
          @object_instance.reflect_on_association(:keywordings).to_hash.should == keywording_associations
          @object_instance.reflect_on_association(:keywords).to_hash.should == keyword_associations
        end

        it "should require user" do
          @object.attributes = item_attributes.except(:user)
          @object.should have(1).error_on(:user)
        end

        it "should require title" do
          @object.attributes = item_attributes.except(:title)
          @object.should have(1).error_on(:title)
        end

        it "should require description" do
          @object.attributes = item_attributes.except(:description)
          @object.should have(1).error_on(:description)
        end

      end
    end
  end

  def container_item_associations(container)
    {
      :macro => :has_many,
      :options => {:through=> "items_#{container.pluralize}".to_sym, :extend=>[]},
      :class_name => container.capitalize
    }
  end

  def user_item_associations
    {
      :macro => :belongs_to,
      :options => {},
      :class_name => "User"
    }
  end

  def items_container_associations(container)
    {
      :macro => :has_many,
      :options => {:dependent=>:delete_all, :as=>:itemable, :extend=>[]},
      :class_name => "Items#{container.capitalize}"
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

