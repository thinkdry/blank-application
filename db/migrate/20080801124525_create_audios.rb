class CreateAudios < ActiveRecord::Migration
  def self.up
    create_table :audios do |t|
      t.integer :user_id
      t.string :title
      t.text :description
     	t.string :state, :default=>"convert"
      t.string :audio_file_name
      t.string :audio_content_type
      t.integer :audio_file_size
      t.datetime :audio_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :audios
  end
end
