class Admin::WebsitesController < Admin::ApplicationController

	# Mixin setting the permission for that controller (see lib/acts_as_authorizable.rb for more)
	acts_as_authorizable(
		:actions_permissions_links => {
      'new' => 'new',
      'create' => 'new',
      'edit' => 'edit',
      'update' => 'edit',
      'show' => 'show',
      'rate' => 'rate',
      'add_comment' => 'comment',
      'destroy' => 'destroy',
      'add_new_user' => 'edit'
    },
		:skip_logging_actions => [:get_website, :load_site, :form_management, :load_news])

  acts_as_container do
  
    after :create do
      unless File.directory? "#{WEBSITES_FOLDER}/#{@current_object.title}"
        FileUtils.makedirs("#{WEBSITES_FOLDER}/#{@current_object.title}/images")
        FileUtils.makedirs("#{WEBSITES_FOLDER}/#{@current_object.title}/stylesheets")
        FileUtils.makedirs("#{WEBSITES_FOLDER}/#{@current_object.title}/javascripts")
      end
    end
    
    before :edit do
      @pages = @current_object.pages
    end
    
    before :update do
      params[:website][:website_url_names] ||= []
      @current_title = @current_object.title
    end
    
    after :update do
      unless params[:website][:title] == @current_title
        rename_website_folder(@current_title, params[:website][:title])
      end
      if params[:website_files]
        @current_object.update_website_resource(params[:website_files])
      end
    end
    
  end
  
  protected
  
  def rename_website_folder(current_folder, new_folder)
    p current_folder
    p new_folder
    command = <<-end_command
         mv #{WEBSITES_FOLDER}/#{current_folder} #{WEBSITES_FOLDER}/#{new_folder}
    end_command
    command.gsub!(/\s+/, " ")
    system(command)
  end
  
end
