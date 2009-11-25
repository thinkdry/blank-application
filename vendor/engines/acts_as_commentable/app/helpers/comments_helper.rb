module CommentsHelper

	# Helper method allowing to print the comments relative to an object passed in paramaeter
	def print_comments_part(object, permission=false)
		render :partial => "comments/comments_part", :locals => { :object => object, :permission => permission }
	end

  def link_to_commentable(comment)
#    comment.commentable.title, "/workspaces/#{comment.commentable.workspaces.last.id}/#{comment.commentable.class.to_s.underscore.pluralize}/#{comment.commentable.id}"
    url = "/admin/workspaces/#{comment.commentable_type == 'Group' ? comment.commentable.workspace.id : comment.commentable.workspaces.last.id}/#{comment.commentable.class.to_s.underscore.pluralize}/#{comment.commentable.id}"
    link_to comment.commentable.title, url
  end
end