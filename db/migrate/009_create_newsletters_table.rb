class CreateNewslettersTable < ActiveRecord::Migration

  def self.up
    create_table :newsletters do |t|
			t.integer :user_id
      t.string  :title,           :limit => 255, :null => false
      t.text    :description,      :null => false
      t.string  :subject,         :limit => 255
      t.string  :from_email,      :limit => 50
			t.string  :state,           :limit => 10
      t.text    :body
      t.integer :viewed_number,   :default => 0
      t.integer :rates_average,   :default => 0
      t.integer :comments_number, :default => 0
			t.timestamps
    end
    add_index :newsletters, :user_id
  end

  def self.down
    drop_table :newsletters
  end
end

