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
        #remember the ck function callback parameter for response script
        ck_callback  = params[:CKEditorFuncNum]

        #render a script that says to CK editor that image is well uploaded, and he can insert it in the body of the item.
        render :text => "<script type='text/javascript'>window.parent.CKEDITOR.tools.callFunction(#{ck_callback}, \"#{uploaded_image.image.url}\")</script>",  :layout => false
      end
    rescue Exception => e
      logger.error(e.to_s + "\n" + e.backtrace.collect { |trace|' ' + trace + "\n" }.to_s)
      render :text => "<script type='text/javascript'>window.parent.CKEDITOR.tools.callFunction(0, '', '', 'error during transfert')", :layout => false
    end
  end
  
  
  def config_file 
    config_file = String.new
    
    config_file += "CKEDITOR.editorConfig = function( config ) { "
    config_file += "config.language = '#{I18n.locale.split('-')[0]}';"
  	config_file += "config.uiColor = '#e6e6e6';"
  	config_file += "config.toolbar = 'BlankToolbar';"
    config_file += "config.height = '400';"
  	config_file += "config.width = '608';"
  	config_file += "config.resize_maxWidth = 608;"
  	config_file += "config.resize_minWidth = 608;"

  	config_file += "config.toolbar_BlankToolbar = ["
  	config_file += "['Save','Source','Undo','Redo','-','Bold','Italic','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],"
  	config_file += "['Link','Unlink','Anchor','Image','Flash','Table','SpecialChar'],"
  	config_file += "['Styles','Format','Font','FontSize','TextColor','BGColor','Maximize','ShowBlocks' ]];"

  	config_file += "config.filebrowserBrowseUrl = '/admin/content_for_popup/all';"
  	config_file += "config.filebrowserImageBrowseUrl = '/admin/content_for_popup/images';"

  	config_file += "config.filebrowserWindowWidth = '640';"
    config_file += "config.filebrowserWindowHeight = '480';"
        
    if params[:ws]
      config_file += "config.filebrowserImageUploadUrl = '/admin/ck_uploads?type=image&ws_id=#{params[:ws]}';"
    else
      config_file += "config.filebrowserImageUploadUrl = '/admin/ck_uploads?type=image';"
    end
  	config_file += "config.LinkUploadAllowedExtensions	= '.(7z|aiff|asf|avi|bmp|csv|doc|fla|flv|gif|gz|gzip|jpeg|jpg|mid|mov|mp3|mp4|mpc|mpeg|mpg|ods|odt|pdf|png|ppt|pxd|qt|ram|rar|rm|rmi|rmvb|rtf|sdc|sitd|swf|sxc|sxw|tar|tgz|tif|tiff|txt|vsd|wav|wma|wmv|xls|xml|zip)$' ;"
    config_file += "};"
    
    render :text => config_file, :layout => false
  end
  
end
