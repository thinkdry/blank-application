class CreateGenericItems < ActiveRecord::Migration
  def self.up
    subqueries = Array.new
    [:article, :image, :artic_file, :audio, :video, :publication].each do |model|
      subqueries << "
        SELECT
          '#{model.to_s.classify}' as item_type,
          id,
          title,
          description,
          created_at,
          updated_at
        FROM #{model.to_s.pluralize}
      "
    end
    
    sql_statement = "CREATE OR REPLACE VIEW generic_items AS "
    sql_statement += subqueries.join(" UNION ALL ")

    execute(sql_statement)
  end

  def self.down
    execute('DROP VIEW generic_items;')
  end
end
