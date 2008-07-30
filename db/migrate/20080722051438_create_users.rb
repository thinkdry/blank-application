class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                      :string, :limit => 40
      t.column :firstname,                  :string, :limit => 255
      t.column :lastname,                   :string, :limit => 255
      t.column :email,                      :string, :limit => 255
      t.column :addr,                       :string, :limit => 500
      t.column :laboratory,                 :string, :limit => 255
      t.column :phone,                      :string, :limit => 255
      t.column :mobile,                     :string, :limit => 255
      t.column :activity,                   :string, :limit => 255
      t.column :edito,                      :text
      # CHANGED: FileColumn instead of Attachment FU
      t.column :image_path,                 :string, :limit => 500
      
      t.column :crypted_password,           :string, :limit => 40
      t.column :salt,                       :string, :limit => 40
      
      t.integer :system_role_id
     
      t.timestamps
     
      t.column :remember_token,             :string, :limit => 40
      t.column :remember_token_expires_at,  :datetime


    end
    add_index :users, :login, :unique => true
  end

  def self.down
    drop_table "users"
  end
end
