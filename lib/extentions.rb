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