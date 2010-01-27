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
      # TODO containers
      if params[:ws_id].nil?
        uploaded_item.associated_workspaces = [@current_user.get_private_workspace.id.to_s]
      else
        uploaded_item.associated_workspaces = [@current_user.get_private_workspace.id.to_s, params[:ws_id]]
      end

      if uploaded_item.save

        #message contains the HTML code to insert in the ck editor
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
  
  
  
  # Action to display tabs that allow user to insert data in CK editor.
 	# insert pics, insert link, insert vids...
 	# it just send to the partial (displayed in a modal windows) the list of available items for display.
  def tabs
          
    if params[:tab_name] != 'links' && params[:tab_name] != 'gallery'
      @current_objects = params[:tab_name].classify.constantize.matching_user_with_permission_in_containers(@current_user, 'show', [current_container.id], current_container_type)
    end
    
    if params[:tab_name] == 'gallery'
      @current_objects = Image.matching_user_with_permission_in_containers(@current_user, 'show', [current_container.id], current_container_type)
    end
    
    render :partial => "/admin/ck_specifics/ck_#{params[:tab_name]}", :locals => {:current_objects => @current_objects}
  end
  
  
  # Action to generate a gallery from CK editor.
  # The user select some pics in a list, gives a name to the gallery, and it display some html code in the ck editor.
  # this function is not very 
  def insert_gallery
    gallery_code = String.new
    
    params[:list_of_pics].each do |pic_id|
      img = Image.find(pic_id)
      gallery_code += '<a href="' + img.image.url + '" rel="' + params[:gallery_name] + '" title="' + img.title + '"><img src="' + img.image.url(:thumb) + '""/></a>'   
    end
    
    gallery_code += '<script type="text/javascript">$(document).ready(function () {$("a[rel=\'' + params[:gallery_name] + '\']").colorbox();});</script>'
    
    render :text => gallery_code
  end
  
  # Save the current edited item by ajax.
  # the user click on ck Save btn, and it save the item body.
  def ajax_item_save
    #TODO translate & DOC
    @current_object = params[:item_type].classify.constantize.find(params[:id])
		if @current_object.update_attribute("body", params[:content])
		  message = "Saved"
		else
		  message = "Unable to Save"
		end
		
		render :text => message, :layout => false
  end
  
  # Save the current edited container by ajax.
  # the user click on ck Save btn, and it save the container description.
  def ajax_container_save
    @current_object = params[:container].classify.constantize.find(params[:id])
  	if @current_object.update_attribute("body", params[:content])
  	  message = "Saved"
  	else
  	  message = "Unable to Save"
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
