class CreateGenericItems < ActiveRecord::Migration
  def self.up  
    subqueries = Array.new
    [:article, :image, :artic_file, :audio, :video, :publication].each do |model|
      subqueries << %{
        SELECT
          '#{model.to_s.classify}' as item_type,
          id,
          user_id,
          title,
          description,
          created_at,
          updated_at
        FROM #{model.to_s.pluralize} }
    end
    
    execute "CREATE OR REPLACE VIEW generic_items AS #{subqueries.join(' UNION ALL ')}"
  end

  def self.down
    execute('DROP VIEW generic_items;')
  end
end
