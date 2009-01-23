class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                      :string, :limit => 40
      t.column :firstname,                  :string, :limit => 255
      t.column :lastname,                   :string, :limit => 255
      t.column :email,                      :string, :limit => 255
      t.column :address,                    :string, :limit => 500
      t.column :company,							      :string, :limit => 255
      t.column :phone,                      :string, :limit => 255
      t.column :mobile,                     :string, :limit => 255
      t.column :activity,                   :string, :limit => 255
			t.column :nationality,								:string, :limit => 255
      t.column :edito,                      :text
      # CHANGED:  PaperClip instead of File Column
      t.string :avatar_file_name
      t.string :avatar_content_type
      t.integer :avatar_file_size
      t.datetime :avatar_updated_at
      t.column :crypted_password,           :string, :limit => 40
      t.column :salt,                       :string, :limit => 40
			t.string :activation_code, :limit => 40
      t.datetime :activated_at
      t.column :password_reset_code,				:string, :limit => 40
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
