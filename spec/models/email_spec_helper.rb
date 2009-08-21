module EmailSpecHelper
  def self.included(base)
    base.module_eval do
      
      describe "Email" do
  
        before(:each) do
          @object = object
        end

        it "should validate presence of from email" do
          @object.attributes = eval("#{@object.class.to_s}_attributes".downcase).except(:email)
          @object.should have(3).errors_on(:email)
        end

        it "should have a valid address" do
          @object.attributes = eval("#{@object.class.to_s}_attributes".downcase)
          @object.email = 'contact#think/com'
          @object.should have(1).error_on(:email)
        end

        it "should have length greater than 6" do
          @object.attributes = eval("#{@object.class.to_s}_attributes".downcase)
          @object.email = 'abc@d.com'
          @object.should have(1).error_on(:email)
        end
        
        it "should have length less than 40" do
          @object.attributes = eval("#{@object.class.to_s}_attributes".downcase)
          @object.email = 'abcdesedefrftgyyhgfgfrredswsswwsadsdffvfttgggrfdd@d.com'
          @object.should have(1).error_on(:email)
        end
      end
    end

    
  end
end