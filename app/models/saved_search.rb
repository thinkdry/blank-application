class SavedSearch < ActiveRecord::Base
    
  belongs_to :user

  serialize :containers
  serialize :items

  validates_presence_of :title

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
      :models => self.items,
      :containers => self.containers,
      :by => "#{self.field}-#{self.order}",
      :per_page => self.limit 
    }
  end  
end
