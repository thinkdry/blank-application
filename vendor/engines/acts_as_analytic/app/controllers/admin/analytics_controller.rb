class Admin::AnalyticsController < Admin::ApplicationController
  unloadable

  def new
    session[:analytic] = nil
    @website = Website.find(params[:website_id])
  end

  def create
    @website = Website.find(params[:website_id])
    session[:analytic] = nil
    if Analytic.setup(params[:login],params[:password])
      session[:analytic] = {:login => params[:login], :password => params[:password]}
      flash[:notice] = I18n.t('analytics.login.message.notice')
      redirect_to website_analytics_path(@website.id)
    else
      flash.now[:error] = I18n.t('analytics.login.message.error')
      render :action => 'new'
    end
  end

  def index
    @website = Website.find(params[:website_id].to_i)
    @website_url = (@website && @website.website_urls) ? @website.website_urls.first : nil
    if !@website_url.nil?
      if File.exist?("#{RAILS_ROOT}/config/customs/google_analytics.yml")
        @analytic_config = YAML.load_file("#{RAILS_ROOT}/config/customs/google_analytics.yml")
        if Analytic.setup(@analytic_config['sa_analytic_login'], @analytic_config['sa_analytic_password']) && @website && @website_url
          begin
            @duration = params[:d] ? params[:d] : 'year'
            @profile = Garb::Account.all.first.profiles.select{|v| v.title =~ /#{@website_url.name}/}.first
            unless @profile.blank?
              visitor_report = Analytic.site_usage(@duration, @profile)
              @visitors_results = visitor_report.last
              @sources_results = Analytic.generic_site_usage(@duration,['source'],['entrances'],@profile)
              @site_mediums_results = Analytic.generic_site_usage(@duration,['medium'],['entrances'],@profile)
              @keywords_results = Analytic.generic_site_usage(@duration,['keyword'],['visits'], @profile)
              @page_paths_results = Analytic.generic_site_usage(@duration,['pagePath'],['pageviews'], @profile)
              @landing_pages_results = Analytic.generic_site_usage(@duration,['landingPagePath'],['entrances'], @profile)
              @exit_pages_results = Analytic.generic_site_usage(@duration,['exitPagePath'],['exits'],@profile)
              month_report = Analytic.generic_site_usage('',['month','day'],['visits','pageviews'], @profile)
              @graphs = Analytic.build_line_graph(month_report)
              @mediums_results, @mediums_graph = Analytic.build_pie_graph(@site_mediums_results)
            else
              flash[:notice] = "No Website Profile exists. \n Please Contact the Administrator."
              redirect_to admin_website_path(@website)
            end
          rescue
            flash[:notice] = "Analytics Not Responding.\n Please Try Later."
            redirect_to admin_website_path(@website)
          end
        else
          flash[:notice] = "Analytics Not Responding.\n Please Try Later."
          redirect_to admin_website_path(@website)
        end
      else
        flash[:notice] = "Analytics Settings do not exist. \n Please Contact the Administrator"
        redirect_to admin_website_path(@website)
      end
    else
      flash[:notice] = "No website is linked to this workspace or no website url exist of this workspace website. \n Please Contact the Administrator"
      redirect_to admin_website_path(@website)
    end
  end
end

