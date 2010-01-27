class Website < ActiveRecord::Base

  acts_as_container
  
  validates_uniqueness_of :title, :message => 'Website title already exists.'
  
  has_many :website_urls, :dependent => :delete_all
  
  has_many :menus, :order => "position"
  
  # Favicon of the website
  has_attached_file :favicon,
                    :url =>  "/#{WEBSITE_FILES}/#{self.name}/favicon/:basename.:extension",
                    :path => ":rails_root/public/#{WEBSITE_FILES}/#{self.name}/favicon/:basename.:extension",
                    :styles => { :default => "16x16>", :medium => "32x32>" }
  # Validation of the size of the attached file
  validates_attachment_size(:favicon, :less_than => 2.megabytes)
  
  # Layout of the website
  has_attached_file :layout,
                    :url =>    "/uploaded_files/websites/layouts/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/websites/layouts/:id/:style/:basename.:extension"
  # Validation of the presence of an attached file
  # validates_attachment_presence :layout
	# Validation of the type of the attached file
  # validates_attachment_content_type :layout
	# Validation of the size of the attached file
  validates_attachment_size(:layout, :less_than => 2.megabytes)
  
  # Sitemap of the website
  has_attached_file :sitemap,
                    :url =>    "/uploaded_files/websites/sitemaps/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/uploaded_files/websites/sitemaps/:id/:style/:basename.:extension"
  # Validation of the presence of an attached file
  # validates_attachment_presence :sitemap
	# Validation of the type of the attached file
  # validates_attachment_content_type :sitemap
	# Validation of the size of the attached file
  validates_attachment_size(:sitemap, :less_than => 2.megabytes)
  
  def update_website_resource(params)
    unless params[:css].blank?
      if File.extname(params[:css].original_filename) == '.css'
        File.open(get_file_path(self.title,"stylesheets",params[:css]), "wb") {
          |f| f.write(params[:css].read)
        }
      elsif File.extname(params[:css].original_filename) == '.zip'
        self.store_assets(params[:css], 'stylesheets')
      end
    end
    unless params[:js].blank?
      if File.extname(params[:js].original_filename) == '.js'
        File.open(get_file_path(self.title,"javascripts",params[:js]), "wb") {
          |f| f.write(params[:js].read)
        }
      elsif File.extname(params[:js].original_filename) == '.zip'
        self.store_assets(params[:js], 'javascripts')
      end
    end
    unless params[:images].blank?
      if File.extname(params[:images].original_filename) == '.zip'
        self.store_assets(params[:images], 'images')
      else
        File.open(get_file_path(self.title,"images",params[:images]), "wb") {
          |f| f.write(params[:images].read)
        }
      end
    end
  end
  
  def store_assets(zip_file, dest_file)
    @upload_file_name = zip_file.original_filename
    FileUtils.makedirs("#{WEBSITES_FOLDER}/#{self.title}/tmp")
    File.open("#{WEBSITES_FOLDER}/#{self.title}/tmp/#{@upload_file_name}", "wb") do |f|
      f.write(zip_file.read)
    end
    zf = Zip::ZipFile.open("#{WEBSITES_FOLDER}/#{self.title}/tmp/#{@upload_file_name}")
    zf.each do |entry|
      if entry.name.split('/').last.include?('.')
        fpath = File.join("#{WEBSITES_FOLDER}/#{self.title}/#{dest_file}/#{entry.name.split('/').last}")
        if(File.exists?(fpath))
          File.delete(fpath)
        end
        zf.extract(entry, fpath)
      end
    end
    FileUtils.rm_rf("#{WEBSITES_FOLDER}/#{self.title}/tmp")
  end

  def include_all_stylesheet_files
    res = ""
    Dir["public/#{WEBSITE_FILES}/#{self.title}/stylesheets/*.css"].collect do |uploaded_css|
    res += "<link href='/#{WEBSITE_FILES}/#{self.title}/stylesheets/#{uploaded_css.split('/')[4]}' rel='stylesheet' type='text/css' />"
    end
   return res
  end

  def include_all_javascript_files
    res = ""
    Dir["public/#{WEBSITE_FILES}/#{self.title}/javascripts/*"].collect do |uploaded_js|
      res += "<script src='/#{WEBSITE_FILES}/#{self.title}/javascripts/#{uploaded_js.split('/')[4]}' type='text/javascript'></script>"
    end
   return res
  end

# to display favicon image in site. Usage: need to call inside of <head> tag in layout
  def display_favicon
    if !self.favicon_file_name.blank?
      return "<link rel='shortcut icon' href='#{self.favicon.url}'/>"
    end
  end

  def website_url_names= params
    tmp = params.uniq
    self.website_urls.each do |k|
      WebsiteUrl.destroy(k.id) unless tmp.delete(k.name)
    end
    tmp.each do |website_url_name|
      self.website_urls.build(:name => website_url_name)
    end
  end

private

  def get_file_path(website,content_type,file)
    return File.join("#{WEBSITES_FOLDER}/#{website}/#{content_type}/", file.original_filename)
  end

end
