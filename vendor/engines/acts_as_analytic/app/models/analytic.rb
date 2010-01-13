require 'garb'
class Analytic
  include Garb::Resource

  def self.site_usage(duration='year',profile=nil)
    report =  Garb::Report.new(profile)
    ['visits','visitors','pageviews','bounces','entrances','exits','newVisits','timeOnSite'].each do |metric|
      report.metrics metric.to_sym
    end
    report.dimensions duration.to_sym
    report.results
  end

  def self.generic_site_usage(duration='',dimensions=[],metrics=[],profile=nil)
    report = Garb::Report.new(profile)
    report.dimensions duration.to_sym unless duration.blank?
    metrics.each do |metric|
      report.metrics metric.to_sym
    end
    dimensions.each do |dimension|
      report.dimensions dimension.to_sym
    end
    report.results
  end

  def self.build_line_graph(report)
    graphs = []
    visits = []
    pageviews = []
    report.each{|e| visits << e.visits.to_i; pageviews << e.pageviews.to_i}
    visits << I18n.t('analytics.graphs.visits')
    pageviews << I18n.t('analytics.graphs.pageviews')
    [visits, pageviews].each do |data|
      title = data.last
      data.pop
      data.pop
      graph = GoogleChart.line_800x200(data.join(','))
      graph.title = title
      data_sum = data.inject{|r,e| r.to_i + e.to_i}
      data_avg = data_sum/data.length.to_i
      graph.colors = '346090'
      graph.label_axis = 'x,y,r'
      graph.label_range = "#{0},#{data.max}"
      graph.label_axis_index = "0:|#{Date.today - 4.month}|#{Date.today - 3.week}|#{Date.today - 2.week}|#{Date.today - 1.week}|#{Date.today}|1:|0|#{data_avg}|#{data.max}|2:|0|#{data_avg}|#{data.max}"
      graphs << graph
    end
    return graphs
  end

  def self.build_pie_graph(mediums_results)
    dir,org,ref = 0,0,0
    mediums_results.each do |r|
      if r.medium == '(none)'
        dir = dir + r.entrances.to_i
      end
      if r.medium == 'organic'
        org = org + r.entrances.to_i
      end
      if r.medium == 'referral'
        ref = ref + r.entrances.to_i
      end
    end
    total = dir + org + ref
    result = {I18n.t('analytics.sources.traffic_sources.graph.direct') => dir, I18n.t('analytics.sources.traffic_sources.graph.search') => org, I18n.t('analytics.sources.traffic_sources.graph.referral') => ref}
    return result, GoogleChart.pie_400x150(I18n.t('analytics.sources.traffic_sources.graph.direct') => ((dir.to_f/total.to_f) * 100), I18n.t('analytics.sources.traffic_sources.graph.search') => ((org.to_f/total.to_f) * 100), I18n.t('analytics.sources.traffic_sources.graph.referral') => ((ref.to_f/total.to_f) * 100))
  end

  def self.duration_format(time_on_site)
    duration = Time.at(time_on_site.to_f).gmtime.strftime('%H:%M:%S')
    return duration
  end

  protected
  def self.setup(login=nil,password=nil)
    Garb::Session.login(login,password)
  rescue
    return false
  end
end

