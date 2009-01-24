class Newpictures < ActiveRecord::Migration
  def self.up
    remove_column :pictures, :picture_path
    add_column :pictures, :picture_file_name, :string
    add_column :pictures, :picture_content_type, :string
    add_column :pictures, :picture_file_size, :integer
    add_column :pictures, :picture_updated_at, :datetime

  end

  def self.down
  end
end
