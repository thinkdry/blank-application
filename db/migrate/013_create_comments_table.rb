class CreateCommentsTable < ActiveRecord::Migration

  def self.up
    create_table :comments do |t|
      t.text    :text,          :null => false
      t.string  :state,          :limit => 15
      t.integer :parent_id
      t.integer :user_id
      t.integer :commentable_id
      t.string  :commentable_type
      t.timestamps
    end
    add_index :comments, :user_id
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
  end

  def self.down
    drop_table :comments
  end
end

