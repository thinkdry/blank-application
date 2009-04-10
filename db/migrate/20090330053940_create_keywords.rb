class CreateKeywords < ActiveRecord::Migration
  def self.up
		create_table :keywords do |t|
			t.integer :user_id
			t.string :name
			t.timestamps
		end

		create_table :keywordings, :id => false do |t|
			t.integer :keywordable_id
			t.string :keywordable_type
			t.integer :keyword_id
			t.integer :user_id
			t.timestamps
		end

  end

  def self.down
		drop_table :keywords
		drop_table :keywordings
  end
end
