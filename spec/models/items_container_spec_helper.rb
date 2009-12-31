module ItemsContainerSpecHelper
  def self.included(base)
    base.module_eval do
      def object
        items_container
      end
      
      describe 'as a items container' do
      
        before(:each) do
          @object = items_container
          @object_name = @object.class.to_s.underscore
          @object_instance = @object_name.classify.constantize
        end
        
        it 'should belong to polymorphic association itemable' do
          @object_instance.reflect_on_association(:itemable).to_hash.should == {
            :macro => :belongs_to,
            :class_name => 'Itemable',
            :options => {:polymorphic => true, :include => :user, :foreign_type=>"itemable_type"}
          }
        end
      end
      
    end
  end
end
