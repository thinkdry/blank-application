module SuperadministrationsHelper

	def checkboxes_from_list(var, param, conf)
		res = ""
		var.each do |l|
      res += check_box_tag(param+"[#{l}]", "1", ((ref=conf["sa_"+param]) ? ref.include?(l) : false))
      res += l+"<br />"
    end
		res += "<br />"
	end

end