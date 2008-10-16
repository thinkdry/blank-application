class UploadsController < ApplicationController
  def create
    begin
      original_filename = params[:NewFile].original_filename
      
      @dest_filename = "#{rand(1000)}_#{params[:NewFile].original_filename}"
      @dest_url = File.join('/uploads', @dest_filename) 
      @dest_path = File.join(RAILS_ROOT, 'public', @dest_url)
      
      File.open(@dest_path, "wb") { |f| f.write(params[:NewFile].read) }
      render :action => 'create', :layout => false
    rescue Exception => e
      logger.error(e.to_s + "\n" + e.backtrace.collect { |trace|' ' + trace + "\n" }.to_s)
      render :action => 'create_failed', :layout => false
    end
  end
end
