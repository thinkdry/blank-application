class CreateElementsTable < ActiveRecord::Migration
  def self.up
    create_table :elements do |t|
      t.string  :name,     :limit => 50
      t.string  :bgcolor,  :limit => 10
      t.string  :template, :limit => 255
      t.timestamps
    end

  end

  def self.down
    drop_table :elements
  end
end

