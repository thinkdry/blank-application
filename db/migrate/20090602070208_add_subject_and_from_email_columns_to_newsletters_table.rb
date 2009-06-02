class AddSubjectAndFromEmailColumnsToNewslettersTable < ActiveRecord::Migration
  def self.up
    add_column :newsletters, :subject, :string
    add_column :newsletters, :from_email, :string
  end

  def self.down
    remove_column :newsletters, :subject
    remove_column :newsletters, :from_email
  end
end
