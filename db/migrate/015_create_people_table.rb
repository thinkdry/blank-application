class CreatePeopleTable < ActiveRecord::Migration

  def self.up
    create_table :people do |t|
      t.string  :first_name,    :limit => 40
      t.string  :last_name,     :limit => 40
	    t.string  :web_page,      :limit => 100
	    t.string  :gender,        :limit => 6
	    t.text    :notes
	    t.string  :email,         :limit => 50, :null => false
	    t.string  :primary_phone, :limit => 25
	    t.string  :mobile_phone,  :limit => 25
	    t.string  :fax,           :limit => 25
	    t.string  :street,        :limit => 40
	    t.string  :city,          :limit => 40
	    t.string  :postal_code,   :limit => 10
	    t.string  :country,       :limit => 50
	    t.string  :company,       :limit => 40
	    t.string  :job_title,     :limit => 40
	    t.integer :user_id
	    t.boolean :newsletter
	    t.string  :salutation,    :limit => 5
	    t.string  :origin,        :limit => 10
	    t.date    :date_of_birth
	    t.timestamps
   end
   add_index :people, :user_id
  end

  def self.down
    drop_table :people
  end
end

