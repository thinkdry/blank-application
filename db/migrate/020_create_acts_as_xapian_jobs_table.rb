class CreateActsAsXapianJobsTable < ActiveRecord::Migration

  def self.up
    create_table :acts_as_xapian_jobs do |t|
      t.string  :model,    :null => false
      t.integer :model_id, :null => false
      t.string  :action,   :null => false
    end
    add_index :acts_as_xapian_jobs, [:model, :model_id], :unique => true
  end

  def self.down
    drop_table :acts_as_xapian_jobs
  end
end

