require 'fileutils'

class Admin::CkToolsController < Admin::ApplicationController

  # Action allowing to upload files with FCKeditor
	#
  # This function is linked to an url accessible from the views.
	# It is uploading the files selected with FCKeditor inside the good folder.
  def upload_from_ck
    begin
      if params[:type] == "image"
           
        #Create a new image
        uploaded_image = Image.new( :title => params[:upload].original_filename,
                                    :description => "uploaded from FCK",
                                    :image => params[:upload].to_s,
                                    :user_id => current_user.id,
                                    :image_file_name => params[:upload].original_filename,                                    
                                    :image => params[:upload]
                                    )
        #YODO : clean this code
        #associate the image in the private of the current user and in the current workspace (if ther is one)
        if params[:ws_id].nil?
          uploaded_image.associated_workspaces = [@current_user.get_private_workspace]
        else
          uploaded_image.associated_workspaces = [@current_user.get_private_workspace, params[:ws_id]]
        end
        
        uploaded_image.save
        
        img_tag = '<img src="' + uploaded_image.image.url + '"/>'
        
        #img_tag = '<embed id="mpl" width="370" height="257" flashvars="&file=http://lacriee.prod.thinkdry.com/uploaded_files/video/58/original/video.flv" allowfullscreen="true" allowscriptaccess="always" quality="high" bgcolor="#666666" src="/videoplayer/player.swf" type="application/x-shockwave-flash"/>'
        
        render :text => "<script type='text/javascript'>window.parent.imageUploadComplete('#{img_tag}');</script>"
      end
    rescue Exception => e
      logger.error(e.to_s + "\n" + e.backtrace.collect { |trace|' ' + trace + "\n" }.to_s)
      #TODO -> display error in notice on top (or error in fck erorrs) 
      render :text => "<script type='text/javascript'>window.parent.CKEDITOR.tools.callFunction(0, '', '', 'error during transfert')", :layout => false
    end
  end
  
  def ajax_item_save
    #TODO translate & DOC
    @current_object = params[:item_type].classify.constantize.find(params[:id])
		if @current_object.update_attribute("body", params[:content])
		  message = "ok"
		else
		  message = "unable to save"
		end
		
		render :text => message
  end
  
  def ajax_workspace_save
    #TODO CONTAINER translate & DOC
    @current_object = Workspace.find(params[:id])
  	if @current_object.update_attribute("description", params[:content])
  	#if current_workspace.update_attribute("description", params[:content])
  	  message = "ok"
  	else
  	  message = "unable to save"
  	end

  	render :text => message
  end
  
  
  #TODO translate & DOC
  def config_file 
    config_file = String.new
    
    config_file += "CKEDITOR.editorConfig = function( config ) { "
    config_file += "config.language = '#{I18n.locale.split('-')[0]}';"
  	config_file += "config.uiColor = '#e6e6e6';"
  	config_file += "config.toolbar = 'BlankToolbar';"
    config_file += "config.height = '400';"
  	config_file += "config.width = '620';"
  	config_file += "config.resize_maxWidth = 608;"
  	config_file += "config.resize_minWidth = 608;"
  	config_file += "config.toolbarCanCollapse = false;"   
    #config_file += "config.contentsCss = '/stylesheets/try.css';"
  	config_file += "config.toolbar_BlankToolbar = ["
  	params[:new] == "true" ? config_file += "[" : config_file += "['Save',"
  	config_file += "'Source','Undo','Redo','-','Bold','Italic','Underline','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','Find','Replace'],"
  	config_file += "['Anchor','Link','Unlink','Table','SpecialChar','Styles','FontSize','TextColor','BGColor', '-','Maximize']];"

  	#config_file += "config.filebrowserBrowseUrl = '/admin/content_for_popup/all';"
  	#config_file += "config.filebrowserImageBrowseUrl = '/admin/content_for_popup/images';"
    #config_file += "config.filebrowserFlashBrowseUrl = '/admin/content_for_popup/videos';"

  	config_file += "config.filebrowserWindowWidth = '640';"
    config_file += "config.filebrowserWindowHeight = '480';"
        
  	#config_file += "config.LinkUploadAllowedExtensions	= '.(7z|aiff|asf|avi|bmp|csv|doc|fla|flv|gif|gz|gzip|jpeg|jpg|mid|mov|mp3|mp4|mpc|mpeg|mpg|ods|odt|pdf|png|ppt|pxd|qt|ram|rar|rm|rmi|rmvb|rtf|sdc|sitd|swf|sxc|sxw|tar|tgz|tif|tiff|txt|vsd|wav|wma|wmv|xls|xml|zip)$' ;"
    config_file += "};"
    
    render :text => config_file, :layout => false
  end
  
end
