module CommentsHelper

	# Helper method allowing to print the comments relative to an object passed in paramaeter
	def print_comments_part(object, permission=false)
		render :partial => "comments/comments_part", :locals => { :object => object, :permission => permission }	
	end
	
	def total_number_of_reply(object)
	  
	  number = 0
	  object.comments.each do |comment|
	    #add the comment to number of comment
	    number += 1
	    #add the number of replies for this comment to number of comments
	    number += comment.replies.size
	  end
	  
	  return number
	end

  def link_to_commentable(comment)
    url = "/admin/workspaces/#{comment.commentable_type == 'Group' ? comment.commentable.workspace.id : comment.commentable.workspaces.last.id}/#{comment.commentable.class.to_s.underscore.pluralize}/#{comment.commentable.id}"
    link_to comment.commentable.title, url
  end
end