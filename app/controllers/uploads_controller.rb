require 'FileUtils'

class UploadsController < ApplicationController
  def create
    begin
      temp_path = params[:NewFile].path
      original_filename = params[:NewFile].original_filename
      
      @dest_filename = "#{rand(1000)}_#{params[:NewFile].original_filename}"
      @dest_url = File.join('/uploads', @dest_filename) 
      @dest_path = File.join(RAILS_ROOT, 'public', @dest_url)
      
      FileUtils.copy(temp_path, @dest_path)
      render :action => 'create', :layout => false
    rescue Exception => e
      render :action => 'create_failed', :layout => false
    end
  end
end
