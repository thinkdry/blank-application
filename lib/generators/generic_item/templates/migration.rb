class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
			t.integer :user_id
      t.string :title
      t.text :description
			t.string :state
<% for attribute in attributes -%>
		t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
			t.timestamps
    end
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
