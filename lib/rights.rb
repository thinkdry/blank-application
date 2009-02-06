module Blank
  module Rights
    
    def create_default_if_empty(type)
      sc_type = type.singularize.capitalize
      if File.exist?("#{RAILS_ROOT}/test/fixtures/#{type}.yml")
        objects = YAML.load_file("#{RAILS_ROOT}/test/fixtures/#{type}.yml")
        objects.each do |k,v|
          aa_object = sc_type.constantize.find_by_name(k)
          unless aa_object
            object = sc_type.constantize.new(:name => v["name"], :description => v["description"])
            object.save!
            puts "#{sc_type} #{v['name']} is created"
          end
        end
      end
    end
    
  end
end