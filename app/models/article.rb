# == Schema Information
# Schema version: 20181126085723
#
# Table name: articles
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  title       :string(255)
#  description :text
#  state       :string(255)
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#  tags        :string(255)
#

class Article < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :body],
                 :values => [ [ :created_at, 0, "created_at", :date ] ]

  	
  has_many :article_files, :dependent => :delete_all
  validates_presence_of :body
  def cdate
    created_at.to_i
  end
  def new_file_attributes= file_attributes
    file_attributes.each do |file_path| 
      article_files.build(:article_id => self.id, :articlefile => file_path)
    end
  end
  
end
