require 'fileutils'

class FckUploadsController < ApplicationController

  # Method to Create File paths & Store Uploaded Files throught FCKEditor
  # 
  # Usage URL:
  #
  # /fck_uploads/
  # 
  def create
    begin
      #original_filename = params[:NewFile].original_filename
      dest_filename = "#{rand(1000)}_#{params[:NewFile].original_filename}"
			dest_folder = "/uploaded_files/#{params[:item_type].downcase}/#{params[:id]}/fck_#{params[:type].downcase}"
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
