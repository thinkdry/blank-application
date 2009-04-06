class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters, :force => true do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state
      t.text :body
      t.string :tags
      t.integer :viewed_number
      t.integer :rates_average
      t.integer :comments_number
      t.string :category
			t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
