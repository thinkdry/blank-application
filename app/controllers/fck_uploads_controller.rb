require 'fileutils'

class FckUploadsController < ApplicationController

  # Upload files with FCKeditor
	#
  # This function is linked to an url accessible from the views.
	# It is uploading the files selected with FCKeditor inside the good folder.
  def create
    begin
      #original_filename = params[:NewFile].original_filename
      dest_filename = "#{rand(1000)}_#{params[:NewFile].original_filename}"
			if params[:item_type] != 'Page'
				dest_folder = "/uploaded_files/#{params[:item_type].downcase}/#{params[:id]}/fck_#{params[:type].downcase.pluralize}"
			else
				object = params[:item_type].classify.constantize.find(params[:id])
				workspace = object.workspaces.delete_if{ |e| e.state == 'private' }.first
				if workspace
					dest_folder = "/uploaded_files/workspace/#{workspace.id}/fck_#{params[:type].downcase.pluralize}"
				else
					render :text => "<script type='text/javascript'>window.parent.OnUploadCompleted(1, '', '', 'No good workspace selected')</script>", :layout => false
				end
			end
			dest_full_path = File.join(RAILS_ROOT, 'public', dest_folder)
			dest_file = File.join(dest_folder, dest_filename)
			FileUtils.makedirs(dest_full_path)
			dest_full_file = File.join(dest_full_path, dest_filename)
			File.open(dest_full_file, "wb") { |f| f.write(params[:NewFile].read) }
			render :text => "<script type='text/javascript'>window.parent.OnUploadCompleted(0, #{(request.url.split(request.request_uri())[0]+dest_file).inspect})</script>", :layout => false		
    rescue Exception => e
      logger.error(e.to_s + "\n" + e.backtrace.collect { |trace|' ' + trace + "\n" }.to_s)
      render :text => "<script type='text/javascript'>window.parent.OnUploadCompleted(1, '', '', #{I18n.t('message.error_during_file_transfer')})</script>", :layout => false
    end
  end
end
