require 'fileutils'

class Admin::CkToolsController < Admin::ApplicationController
  
  #TODO translate & DOC
  def config_file 
    config_file = String.new
    
    config_file += "CKEDITOR.editorConfig = function( config ) { "
    config_file += "config.language = '#{I18n.locale.split('-')[0]}';"
  	config_file += "config.uiColor = '#e6e6e6';"
  	config_file += "config.toolbar = 'BlankToolbar';"
    config_file += "config.height = '400';"
  	config_file += "config.width = '632';"
  	config_file += "config.resize_maxWidth = 620;"
  	config_file += "config.resize_minWidth = 620;"
  	config_file += "config.toolbarCanCollapse = false;"   

  	config_file += "config.toolbar_BlankToolbar = ["
  	params[:new] == "true" ? config_file += "[" : config_file += "['Save',"
  	config_file += "'Source','Undo','Redo','-','Bold','Italic','Underline','NumberedList','BulletedList','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','Find','Replace'],"
  	config_file += "['Anchor','Link','Unlink','Table','SpecialChar','Styles','FontSize','TextColor','BGColor', '-','Maximize']];"

  	config_file += "config.filebrowserWindowWidth = '640';"
    config_file += "config.filebrowserWindowHeight = '480';"
    
    config_file += "};"
    
    render :text => config_file, :layout => false
  end
  
  # Action allowing to upload files with FCKeditor
	#
  # This function is linked to an url accessible from the views.
	# It is uploading the files selected with FCKeditor inside the good folder.
  def upload_from_ck
    begin
      #TODO translate, dynamics messages
      uploaded_item = params[:item_type].classify.constantize.new(:title => params[:upload].original_filename,
                                                                  :description => "uploaded from FCK",
                                                                  params[:item_type].to_sym => params[:upload],
                                                                  :user_id => current_user.id
                                                                  )
      # TODO 
      if params[:ws_id].nil?
        uploaded_item.associated_workspaces = [@current_user.get_private_workspace.id.to_s]
      else
        uploaded_item.associated_workspaces = [@current_user.get_private_workspace.id.to_s, params[:ws_id]]
      end

      if uploaded_item.save

        case params[:item_type]
          when "image"
            message = upload_image(uploaded_item)
          when "video"
            message = upload_video(uploaded_item)
          when "audio"
            message = upload_audio(uploaded_item)
          else
            render :text => '<script type="text/javascript">$(\'#notice\').showMessage("no type available", 1500);</script>'
        end
      
      else
        render :text => '<script type="text/javascript">$(\'#notice\').showMessage("error while saving", 1500);</script>'
      end
      
      render :text => message
      
    rescue Exception => e
      logger.error(e.to_s + "\n" + e.backtrace.collect { |trace|' ' + trace + "\n" }.to_s)
      #TODO -> display error in notice on top (or error in fck erorrs) 
      render :text => '<script type="text/javascript">$(\'#notice\').showMessage("error during transfert", 1500);</script>', :layout => false
    end
  end
  
  def tabs
    render :partial => "/admin/ck_specifics/ck_#{params[:tab_name]}"
  end
  
  def ajax_item_save
    #TODO translate & DOC
    @current_object = params[:item_type].classify.constantize.find(params[:id])
		if @current_object.update_attribute("body", params[:content])
		  message = "Saved"
		else
		  message = "Unable to save"
		end
		
		render :text => message, :layout => false
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

  	render :text => '<script type="text/javascript">$(\'#notice\').showMessage("#{message}", 1500);</script>', :layout => false
  end
  
  protected
  
  def upload_image(object)
    img_tag = '<img src="' + object.image.url + '"/>'
  
    return "<script type=\"text/javascript\">window.parent.itemUploadComplete('#{img_tag}');</script>"
  end

  def upload_video(object)
		vdo_tag =  '<embed width="370" height="257" '
		vdo_tag += 'flashvars="&image=' + File.dirname(object.video.url)
		vdo_tag += '/2.png&file=' + File.dirname(object.video.url)
		vdo_tag += '/video.flv" allowfullscreen="true" allowscriptaccess="always" quality="high" src="/players/videoplayer.swf" type="application/x-shockwave-flash"/>'
		
		return "<script type=\"text/javascript\">window.parent.itemUploadComplete('#{vdo_tag}');</script>"
  end
  
  def upload_audio(object)
    audio_tag = '<embed allowfullscreen="true" allowscriptaccess="always" quality="high"'
		audio_tag += ' flashvars="&playerID=1&soundFile=' + object.path_to_encoded_file
		audio_tag += '" src="/players/audioplayer.swf" type="application/x-shockwave-flash"/>'
  
		return "<script type=\"text/javascript\">window.parent.itemUploadComplete('#{audio_tag}');</script>"
  end
end
