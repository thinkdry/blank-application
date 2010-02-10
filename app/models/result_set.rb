require 'friendly_url'
class ResultSet < ActiveRecord::Base
  acts_as_item

  belongs_to :menu

  serialize :containers
  serialize :items

  before_save :set_title_sanitized

  def set_title_sanitized
    self['title_sanitized'] =  self.title.humanize.urlize
  end
  
  CONTAINERS.each do |container|
    define_method "selected_#{container}s".to_sym do
      result = []
      if self.containers[container.to_s]
        self.containers[container.to_s].each do |e|
          result << container.classify.constantize.find(e.to_i, :select => 'id, title')
        end
      end
      result  
    end
  end

  def self.to_db(params)
    SavedSearch.new(
      :q => params[:q] ? params[:q] : nil,
      :field => params[:filter][:field] ? params[:filter][:field] : nil,
      :order => params[:filter][:way] ? params[:filter][:way] : nil,
      :limit => params[:filter][:limit] ? params[:filter][:limit] : nil,
      :created_at_after => params[:created_at_after] ? params[:created_at_after] : nil,
      :created_at_before => params[:created_at_before] ? params[:created_at_before] : nil ,
      :containers  => params[:containers] ? params[:containers] : nil
      )
  end

  def make_params
    {
      :q => self.q,
      :m => self.items,
      :containers => self.containers,
      :by => "#{self.field}-#{self.order}",
      :per_page => self.limit 
    }
  end  
  
end
