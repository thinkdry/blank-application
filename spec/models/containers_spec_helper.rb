module ContainersSpecHelper
  def self.included(base)
    base.module_eval do
      fixtures :users
      
      def object
        container
      end

      describe 'as a container' do
        
        before(:each) do
          @object = container
          @object_name = container.class.to_s.underscore
          @object_instance = @object_name.classify.constantize
        end

        it "should require title" do
          @object.attributes = container_attributes.except(:title)
          @object.should have(1).error_on(:title)
        end

        it "should require description" do
          @object.attributes = container_attributes.except(:description)
          @object.should have(1).error_on(:description)
        end
        
        it 'should require available_items' do
          @object.attributes = container_attributes.except(:available_items)
          @object.should have(1).error_on(:available_items)
        end

        it "has many users containers" do
          @object_instance.reflect_on_association(:users_containers).to_hash.should == {
            :macro => :has_many,
            :options => {:as => :containerable, :dependent=>:delete_all, :extend=>[]},
            :class_name => "UsersContainer"
          }
        end

        it "has many users through user containers" do
          @object_instance.reflect_on_association(:users).to_hash.should =={
            :macro => :has_many,
            :options => {:through => :users_containers, :extend=>[]},
            :class_name => 'User'
          }
        end

        it "has many roles through user container" do
          @object_instance.reflect_on_association(:roles).to_hash.should == {
            :macro => :has_many,
            :options => {:through => :users_containers, :extend => []},
            :class_name => 'Role'
          }
        end
        
        ITEMS.each do |item|
          it "has many #{item.pluralize}" do
            @object_instance.reflect_on_association(item.pluralize.to_sym).to_hash.should == {
              :macro => :has_many,
              :class_name => item.classify,
              :options => {
                :source => :itemable,
                :through => "items_#{@object_name.pluralize}".to_sym,
                :source_type => item.classify.to_s, :class_name => item.classify.to_s,
                :extend=>[]
               }
            }
          end
        end
        
        it 'has many feed items from feed sources' do
          @object_instance.reflect_on_association(:feed_items).to_hash.should == {
            :macro => :has_many,
            :class_name => 'FeedItem',
            :options => {:through => :feed_sources, :extend => []}
          }
        end
        
        it "has many items container" do
          @object_instance.reflect_on_association("items_#{@object_name.pluralize}".to_sym).to_hash.should == {
            :macro => :has_many,
            :options => {:extend=>[], :dependent=>:delete_all},
            :class_name => "Items#{@object_name.capitalize}"
          }
        end

        it "belongs to creator" do
          @object_instance.reflect_on_association(:creator).to_hash.should == {
            :macro => :belongs_to,
            :options => {:class_name => 'User'},
            :class_name => 'Creator'
          }
        end
      end
    end
  end
  
  def container_attributes
    {
      :creator_id => users(:luc).id,
      :title => 'My Container',
      :description => 'My Container Description',
      :available_items => %w{article image cms_file video audio feed_source bookmark newsletter group}
    }
  end
  
  def container
    raise 'Container must be defined'
  end
  
end
