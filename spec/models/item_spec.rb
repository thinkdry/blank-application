require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
 fixtures :items, :articles

  def item
    Item.new
  end

  before(:each) do
    @item = items(:one)
  end

  it "should belong to a workspace" do
    Item.reflect_on_association(:workspace).to_hash.should =={
        :macro => :belongs_to,
        :options => {},
        :class_name => 'Workspace'
      }
  end

  it "should be itemable" do
    Item.reflect_on_association(:itemable).to_hash.should == {
      :macro => :belongs_to,
      :options => {:include => :user, :polymorphic => true, :foreign_type=>"itemable_type"},
      :class_name => 'Itemable'
    }
  end

  it "should return the object of the item type" do
    @item.get_item.should == articles(:one)
  end

  it "should return title of the item" do
    @item.title.should == 'test article'
  end

  it "should return description of the item" do
    @item.description.should == 'test article description'
  end

end