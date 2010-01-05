class Website < ActiveRecord::Base

  acts_as_container
  
  has_many :website_urls, :dependent => :delete_all
  
  # Favicon of the website
  has_attached_file :favicon,
                    :url =>  "/front_files/#{self.name}/favicon/:basename.:extension",
                    :path => ":rails_root/public/front_files/#{self.name}/favicon/:basename.:extension",
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
  
  def store_assets(zip_file, dest_file)
    @upload_file_name = zip_file.original_filename
    FileUtils.makedirs("#{RAILS_ROOT}/public/front_files/#{self.name}/tmp")
    File.open("#{RAILS_ROOT}/public/front_files/#{self.name}/tmp/#{@upload_file_name}", "wb") do |f|
      f.write(zip_file.read)
    end
    zf = Zip::ZipFile.open("#{RAILS_ROOT}/public/front_files/#{self.name}/tmp/#{@upload_file_name}")
    zf.each do |entry|
      if entry.name.split('/').last.include?('.')
        fpath = File.join("#{RAILS_ROOT}/public/front_files/#{self.name}/#{dest_file}/#{entry.name.split('/').last}")
        if(File.exists?(fpath))
          File.delete(fpath)
        end
        zf.extract(entry, fpath)
      end
    end
    FileUtils.rm_rf("#{RAILS_ROOT}/public/front_files/#{self.name}/tmp")
  end

	def include_all_stylesheet_files
		res = ""
		Dir["public/front_files/#{self.name}/stylesheets/*"].collect do |uploaded_layout|
			res += "<link href='/front_files/#{self.name }/stylesheets/#{uploaded_layout.split('/')[4]}' rel='stylesheet' type='text/css' />"
		end
		return res
	end

	def include_all_javascript_files
		res = ""
		res += "<script type='text/javascript' src='/front_files/javascripts/front_application.js'></script>"
		Dir["public/front_files/#{self.name}/javascripts/*"].collect do |uploaded_layout|
			res += "<script src='/front_files/#{self.name }/javascripts/#{uploaded_layout.split('/')[4]}' type='text/javascript'></script>"
		end
	end

	# to display favicon image in site. Usage: need to call inside of <head> tag in layout
  def display_favicon
    if !self.favicon_file_name.blank?
      return "<link rel='shortcut icon' href='#{self.favicon.url}'/>"
    end
  end

  
  

end
