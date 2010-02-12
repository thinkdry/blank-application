class ApplicationController < ActionController::Base

  # Library used by the 'restful_authentcation' (and providing 'current_user' method)
	include AuthenticatedSystem

  include ExceptionNotifiable
  # Captcha Management
	include YacaphHelper
  # Configuration
  include Configuration

  before_filter :get_configuration
	
	helper :yacaph, :websites

  helper_method :setting_searching_params, :current_website

  def setting_searching_params(*args)
		options = args.extract_options!
		if options[:from_params]
			options = options[:from_params]#.merge({ :cat => nil, :models => nil })
		end
		return {
			:user => @current_website.creator,
			:permission => 'show',
			:models => options[:m] || (options[:cat] ? ((options[:cat] == 'item') ? @configuration['sa_items'] : [options[:cat]]) : @configuration['sa_items']),
      :containers => options[:containers],
			:full_text => (options[:q] && !options[:q].blank? && options[:q] != I18n.t('layout.search.search_label')) ? options[:q] : nil,
			:filter => { :field => options[:by] ? options[:by].split('-').first : 'created_at', :way => options[:by] ? options[:by].split('-').last : 'desc' },
			:pagination => { :page => options[:page] || 1, :per_page => options[:per_page] || get_per_page_value },
			:opti => options[:opti] ? options[:opti] : 'skip_pag_but_filter'
			}
	end

  def current_website
		site_url = params[:site_url] || request.url.split('//').second.split('/').first
		#wsu = WebsiteUrl.find_by_sql("SELECT website_urls.website_id FROM website_urls WHERE website_urls.name = '#{ws_url}' LIMIT 1").first
		if params[:site_title] && Website.exists?(:title => params[:site_title], :website_state => 'published')
      @current_website = Website.find_by_title(params[:site_title])
      session[:website_id] = @current_website.id
      return true
    elsif WebsiteUrl.exists?(:name => site_url)
      @current_website = WebsiteUrl.find_by_name(site_url).website
			session[:website_id] = @current_website.id
			return true
		else
			return false
		end
  end

	
end

