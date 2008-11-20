class CreateFeedSources < ActiveRecord::Migration
  def self.up
    create_table  :feed_sources do |t|
      t.integer   :user_id
      t.string    :name
      t.text      :description
      t.string    :url, :limit => 1024
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_sources
  end
end
