class AddNewWebsiteColumns < ActiveRecord::Migration
  def self.up
    add_column :websites, :contact_email, :string
    add_column :websites, :home_page_id, :integer
    add_column :websites, :mail_page_id, :integer
    add_column :websites, :gallery_page_id, :integer
    add_column :websites, :intro_page_id, :integer
    add_column :websites, :favicon_file_name, :string
    add_column :websites, :favicon_content_type, :string
    add_column :websites, :favicon_file_size, :string
    add_column :websites, :layout_file_name, :string
    add_column :websites, :layout_content_type, :string
    add_column :websites, :layout_file_size, :string
    add_column :websites, :sitemap_file_name, :string
    add_column :websites, :sitemap_content_type, :string
    add_column :websites, :sitemap_file_size, :string
    add_column :websites, :body_size, :string
    add_column :websites, :website_state, :string, :default => 'under_construction'
  end

  def self.down
    drop_column :websites, :contact_email
    drop_column :websites, :home_page_id
    drop_column :websites, :mail_page_id
    drop_column :websites, :gallery_page_id
    drop_column :websites, :intro_page_id
    drop_column :websites, :favicon_file_name
    drop_column :websites, :favicon_content_type
    drop_column :websites, :favicon_file_size
    drop_column :websites, :layout_file_name
    drop_column :websites, :layout_content_type
    drop_column :websites, :layout_file_size
    drop_column :websites, :sitemap_file_name
    drop_column :websites, :sitemap_content_type
    drop_column :websites, :sitemap_file_size
    drop_column :websites, :body_size
    drop_column :websites, :website_state
  end
end
