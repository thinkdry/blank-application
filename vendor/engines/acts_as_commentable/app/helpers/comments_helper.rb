module CommentsHelper

	def print_comments_part(object)
		render :partial => "comments/comments_part", :locals => { :object => object }
	end

end