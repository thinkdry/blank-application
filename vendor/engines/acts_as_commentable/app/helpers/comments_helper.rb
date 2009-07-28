module CommentsHelper

	# Helper method allowing to print the comments relative to an object passed in paramaeter
	def print_comments_part(object)
		render :partial => "comments/comments_part", :locals => { :object => object }
	end

end