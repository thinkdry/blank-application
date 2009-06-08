class NewReplyOnCommentColumn < ActiveRecord::Migration
  def self.up
    add_column :comments, :parent_id, :integer
  end

  def self.down
  end
end
