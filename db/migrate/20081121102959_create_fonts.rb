class CreateFonts < ActiveRecord::Migration
  def self.up
    create_table :fonts do |t|
      t.string :name
      t.string:type
      t.string:weight
      t.string :template ,:default=>"current"
      t.integer:element_id
      t.timestamps
    end
  end

  def self.down
    drop_table :fonts
  end
end
