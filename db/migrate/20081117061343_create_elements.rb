class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.string:name
      t.string:bgcolor
      t.string:layout
      t.timestamps
    end
    Element.create(:name=>"header",:bgcolor=>"#FFFFFF",:layout=>"default")
    Element.create(:name=>"body",:bgcolor=>"#FFFFFF",:layout=>"default")
    Element.create(:name=>"right",:bgcolor=>"#FFFFFF",:layout=>"default")
    Element.create(:name=>"footer",:bgcolor=>"#666666",:layout=>"default")
    Element.create(:name=>"top",:bgcolor=>"#D86C27",:layout=>"default")
    Element.create(:name=>"search",:bgcolor=>"#666666",:layout=>"default")
    Element.create(:name=>"ws",:bgcolor=>"#FF9933",:layout=>"default")
    Element.create(:name=>"border",:bgcolor=>"#D86C27",:layout=>"default")
    Element.create(:name=>"accordion",:bgcolor=>"#666666",:layout=>"default")
    Element.create(:name=>"links",:bgcolor=>"#D86C27",:layout=>"default")
    Element.create(:name=>"clicked",:bgcolor=>"#FF9933",:layout=>"default")
  end

  def self.down
    drop_table :elements
  end
end
