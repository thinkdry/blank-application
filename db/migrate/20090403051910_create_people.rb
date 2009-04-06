class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
	    t.string :web_page
	    t.string :gender
	    t.text :notes
	    t.string :email
	    t.string :primary_phone
	    t.string :mobile_phone
	    t.string :fax
	    t.string :street
	    t.string :city
	    t.string :postal_code
	    t.string :country
	    t.string :company
	    t.string :job_title

      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
