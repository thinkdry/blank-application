class AddColumn < ActiveRecord::Migration
  def self.up
		add_column :comments, :state, :string
  end

  def self.down
  end
end
