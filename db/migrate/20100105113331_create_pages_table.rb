class CreatePagesTable < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :user_id
      t.string  :title,           :limit => 255, :null => false
      t.text    :description,     :null => false
			t.string  :state,           :limit => 15
      t.text    :body
      t.string  :page_title
      t.string  :page_type,       :limit => 50
      t.string  :menu_title,      :limit => 50
      t.string  :title_sanitized
      t.integer :viewed_number,   :default => 0
      t.integer :comments_number, :default => 0
      t.integer :rates_average,   :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
