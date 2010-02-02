class Admin::ZipUploadsController < Admin::ApplicationController
  
  before_filter :check_permission
  
  def new 
    
  end
  
  def create
    if params[:file] && params[:file][:zip]
      if File.extname(params[:file][:zip].original_filename) == '.zip'
        file = params[:file][:zip]
        file_name = file.original_filename
        file_ext = File.extname(file_name)
        dir_path = "#{RAILS_ROOT}/public/zip/tmp"
        FileUtils.makedirs(dir_path)
        File.open("#{dir_path}/#{file_name}", "wb") do |f|
          f.write(file.read)
        end
        zf = Zip::ZipFile.open("#{dir_path}/#{file_name}")
        zf.each do |entry|
          if (e = entry.name.split('/').last).include?('.')
            fpath = File.join("#{dir_path}/#{e}")
              if(File.exists?(fpath))
                File.delete(fpath)
              end
            zf.extract(entry, fpath)
            upload_file(fpath)
          end
        end
        FileUtils.rm_rf("#{dir_path}")
        flash[:notice] = "Files Saved Successfully in #{current_container.title}"
        respond_to do |format|
          format.html{redirect_to edit_container_zip_upload_path(current_container)}
        end
      else
        flash[:error] = "Enter a file with .zip extension" 
        render :action => 'new'
      end
    else
      render :action => 'new'
    end
  end

  def edit
    get_zipped_items
    if @images.empty? && @audios.empty? && @videos.empty? && @cms_files.empty?
      flash[:notice] = "No Uploaded Zip Items for Edition"
      redirect_to container_path(current_container)
    end
  end

  def update
    %W{images audios videos cms_files}.each do |item|
      if params["#{item}".to_sym]
        instance_variable_set "@#{item}", item.classify.constantize.update(params["#{item}"].keys, params["#{item}"].values.each{|v| v.merge!(:source => 'form')}).reject{|i| i.errors.empty?}
      end
    end
    if @images && @images.empty? && @audios && @audios.empty? && @videos && @videos.empty? && @cms_files && @cms_files.empty?
      flash[:notice] = "Updated All Items"
      redirect_to container_path(current_container)
    else
      @images ||= [] 
      @audios ||= []
      @videos ||= []
      @cms_files ||= []
      flash[:notice] = "Updation of some items failed"
      render :action => 'edit'
    end
  end

protected

  def check_permission
    no_permission_redirection unless current_container.has_permission_for?('new', current_user, current_container_type)
  end

  def get_zipped_items
    @images = current_container.images.find(:all,:conditions => {:source => 'zip'})
    @audios = current_container.audios.find(:all,:conditions => {:source => 'zip'})
    @videos = current_container.videos.find(:all,:conditions => {:source => 'zip'})
    @cms_files = current_container.cms_files.find(:all,:conditions => {:source => 'zip'})
  end
  

  # TODO Dirty work move to model
  def upload_file(file_path)
    ext = File.extname(file_path).downcase
    CONTAINERS.each do |container|
      instance_variable_set "@#{container}_ids", []
    end
    file_name = File.basename(file_path)
    private_workspace = current_user.private_workspace
    available_items = private_workspace.available_items.split(',') & current_container.available_items.split(',')
    @workspace_ids << private_workspace.id
    if current_container != private_workspace
      eval("@#{current_container_type}_ids << #{current_container.id}")        
    end
    if ['.png','.jpeg','.gif','.jpg','.bmp'].include?(ext) && available_items.include?('image')
      i = Image.new(:title => file_name, :description => file_name, :user_id => current_user.id, :source => 'zip')
      i.image = File.new(file_path)
      CONTAINERS.each do |container|
        i.send("associated_#{container.pluralize}=", eval("@#{container}_ids"))
      end
      if i.save
        logger.info("Image with id #{i.id} created")
      end
      elsif ['.wav','.mp3','.wma','.mp4'].include?(ext) && available_items.include?('audio')
      i = Audio.new(:title => file_name, :description => file_name, :user_id => current_user.id, :source => 'zip')
      i.audio = File.new(file_path)
      CONTAINERS.each do |container|
        p ">>>>>>>>>>>>>>>>>>>>>.."
        p container
        p eval("@#{container}_ids")
        i.send("associated_#{container.pluralize}=", eval("@#{container}_ids"))
      end
      i.save
      if i.save
        i.update_attributes(:state => 'uploaded')
        Delayed::Job.enqueue(EncodingJob.new({:type=>"audio", :id => i.id, :enc=>"mp3"}))
        logger.info("Audio with id #{i.id} created")
      end
      elsif [".mov", ".mpeg", ".mpg", ".3gp", ".flv", ".avi"].include?(ext) && current_container.available_items.split(',').include?('video')
      i = Video.new(:title => file_name, :description => file_name, :user_id => current_user.id, :source => 'zip')
      i.video = File.new(file_path)
      CONTAINERS.each do |container|
        i.send("associated_#{container.pluralize}=", eval("@#{container}_ids"))
      end
      if i.save
        i.update_attributes(:state => 'uploaded')
        Delayed::Job.enqueue(EncodingJob.new({:type=>"video", :id => i.id, :enc=>"flv"}))
        logger.info("Video with id #{i.id} created")
      end
      elsif [".txt",".doc",".pdf"].include?(ext) && available_items.include?('cms_file')
      i = CmsFile.new(:title => file_name, :description => file_name, :user_id => current_user.id, :source => 'zip')
      i.cmsfile = File.new(file_path)
      CONTAINERS.each do |container|
        i.send("associated_#{container.pluralize}=", eval("@#{container}_ids"))
      end
      if i.save
        logger.info("CmsFile with id #{i.id} created")
      end
    else
      logger.error("Item with extension #{ext} is not allowed")  
    end
  end

end
