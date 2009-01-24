class Favicons < ActiveRecord::Migration
  def self.up
    add_column :pictures, :favicon_file_name, :string
    add_column :pictures, :favicon_content_type, :string
    add_column :pictures, :favicon_file_size, :integer
    add_column :pictures, :favicon_updated_at, :datetime
    Picture.create(:name=>"favicon")
  end

  def self.down
  end
end
