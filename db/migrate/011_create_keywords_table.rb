class CreateKeywordsTable < ActiveRecord::Migration

  def self.up
    create_table :keywords do |t|
			t.integer :user_id
			t.string  :name, :limit => 40
			t.timestamps
		end
    add_index :keywords, :user_id

		create_table :keywordings, :id => false do |t|
			t.integer :keywordable_id
			t.string  :keywordable_type, :limit => 40
			t.integer :keyword_id
			t.integer :user_id
			t.timestamps
    end
    add_index :keywordings, :keyword_id
    add_index :keywordings, :keywordable_id
    add_index :keywordings, :keywordable_type
    add_index :keywordings, :user_id
  end

  def self.down
    drop_table :keywords
		drop_table :keywordings
  end
end

