module Extentions

	module HashFeatures

				def self.extended(base)
					base.keys.each do |e|
							define_method e do
								base[e]
							end
					end
				end

	end

end

Array.class_eval do
	def sort_with_filter(filter_field, filter_way)
		return self.sort!{|a, b|
        if filter_way == 'desc'
          a.send(filter_field) <=> b.send(filter_field)
        else
          b.send(filter_field) <=> a.send(filter_field)
        end
      }
	end
end