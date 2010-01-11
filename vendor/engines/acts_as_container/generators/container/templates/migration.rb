class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %>, :force => true do |t|
			t.integer :creator_id,                        :null => false
      t.string  :title,              :limit => 255, :null => false
      t.string  :description,                        :null => false
      t.string  :state,              :limit => 15
      t.string  :available_items,    :limit => 255
      t.string  :logo_file_name,     :limit => 255
      t.string  :logo_content_type,  :limit => 100
      t.integer :logo_file_size
      t.string  :available_types,    :limit => 255
      <% for attribute in attributes -%>
		  t.<%= attribute.type %> :<%= attribute.name %>
      <% end -%>
			t.timestamps
    end
    
    create_table :items_<%= table_name %>, :force => true do |t|
			t.integer :<%= class_name.underscore %>_id, :null => false
      t.integer :itemable_id, :null => false
      t.string  :itemable_type, :null => false
			t.timestamps
    end
    
    add_index :<%= table_name %>, :creator_id
    add_index :items_<%= table_name %>, :<%= class_name.underscore %>_id
    add_index :items_<%= table_name %>, :itemable_id
    add_index :items_<%= table_name %>, :itemable_type
    
  end

  def self.down
    drop_table :<%= table_name %>
    drop_table :items_<%= table_name%>
  end
end
