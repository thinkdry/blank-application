class CreatePublicItems < ActiveRecord::Migration
  def self.up
    create_table :public_items do |t|
			t.integer :itemable_id
			t.string :itemable_type
			t.integer :extranet_category_id
			t.integer :suggester_id
			t.integer :validated
			
      t.timestamps
    end
  end

  def self.down
    drop_table :public_items
  end
end
