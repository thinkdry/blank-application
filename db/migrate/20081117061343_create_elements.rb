class CreateElements < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.string:name
      t.string:bgcolor
      t.string:template
      t.timestamps
    end
    Element.create(:name=>"header",:bgcolor=>"#FFFFFF",:template=>"current")
    Element.create(:name=>"body",:bgcolor=>"#FFFFFF",:template=>"current")
    
  end

  def self.down
    drop_table :elements
  end
end
