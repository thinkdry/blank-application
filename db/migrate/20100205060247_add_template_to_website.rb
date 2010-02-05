class AddTemplateToWebsite < ActiveRecord::Migration
  def self.up
    add_column :websites, :template, :string, :default => 'default'
  end

  def self.down
    drop_column :websites, :template
  end
end
