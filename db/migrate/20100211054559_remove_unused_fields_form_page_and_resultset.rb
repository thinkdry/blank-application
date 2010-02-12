class RemoveUnusedFieldsFormPageAndResultset < ActiveRecord::Migration
  def self.up
    remove_column :pages, :page_title
    remove_column :pages, :page_type
    remove_column :pages, :menu_title
    remove_column :pages, :title_sanitized
    remove_column :result_sets, :page_title
    remove_column :result_sets, :title_sanitized
    rename_column :menus, :page_title, :seo_title
    remove_column :websites, :home_page_id
    remove_column :websites, :mail_page_id
    remove_column :websites, :gallery_page_id
    remove_column :websites, :intro_page_id
    ITEMS.each do |item|
      remove_column item.pluralize.to_sym, :published
      add_column item.pluralize.to_sym, :title_sanitized, :string
    end
  end

  def self.down
    add_column :pages, :page_title, :string
    add_column :pages, :page_type, :string
    add_column :pages, :menu_title, :string
    add_column :pages, :title_sanitized, :string
    add_column :result_sets, :page_title, :string
    rename_column :menus, :seo_title, :page_title
    add_column :websites, :home_page_id, :integer
    add_column :websites, :mail_page_id, :integer
    add_column :websites, :gallery_page_id, :integer
    add_column :websites, :intro_page_id, :integer
  end
end
