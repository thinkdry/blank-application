class CreateAudiosTable < ActiveRecord::Migration

  def self.up
    create_table :audios do |t|
      t.integer  :user_id
      t.string   :title,             :limit => 255, :null => false
      t.text     :description,       :null => false
      t.string   :audio_file_name,    :limit => 100
      t.string   :audio_content_type, :limit => 20
      t.integer  :audio_file_size
      t.datetime :audio_updated_at
			t.string   :state,             :limit => 15
      t.integer  :viewed_number,     :default => 0
      t.integer  :comments_number,   :default => 0
      t.integer  :rates_average,     :default => 0
      t.timestamps
    end
    add_index :audios, :user_id
  end

  def self.down
    drop_table :audios
  end
end

