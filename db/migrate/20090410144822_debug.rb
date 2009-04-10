class Debug < ActiveRecord::Migration
  def self.up
    remove_column :keywordings, :keywordable_type
		add_column :keywordings, :keywordable_type, :string
  end

  def self.down
    
  end
end
