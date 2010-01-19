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
      unless File.directory? "#{RAILS_ROOT}/public/website_files/#{@current_object.title}"
        FileUtils.makedirs("#{RAILS_ROOT}/public/website_files/#{@current_object.title}/images")
        FileUtils.makedirs("#{RAILS_ROOT}/public/website_files/#{@current_object.title}/stylesheets")
        FileUtils.makedirs("#{RAILS_ROOT}/public/website_files/#{@current_object.title}/javascripts")
      end
    end
    
    before :edit do
      @pages = @current_object.pages
    end
    
    before :update do
      params[:website][:website_url_names] ||= []
    end
    
    after :update do
      if params[:website_files]
        @current_object.update_website_resource(params[:website_files])
      end
    end
    
  end
end
