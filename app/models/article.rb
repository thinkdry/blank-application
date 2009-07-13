# == Schema Information
# Schema version: 20181126085723
#
# Table name: articles
#
#  id              :integer(4)      not null, primary key
#  user_id         :integer(4)
#  title           :string(255)
#  description     :text
#  state           :string(255)
#  body            :text
#  created_at      :datetime
#  updated_at      :datetime
#  tags            :string(255)
#  viewed_number   :integer(4)
#  rates_average   :integer(4)
#  comments_number :integer(4)
#  category        :string(255)
#

class Article < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  # Item specific Library - /lib/acts_as_item
  acts_as_item

  has_many :article_files, :dependent => :delete_all

  # Validation's
  validates_presence_of :body, :on => :update

  acts_as_xapian :texts => [:title, :description, :keywords_list, :body]
  
  # Association of Files to Article using PaperClip
  # 
  # file_attributes are the associated files using paperclip attachment
  def new_file_attributes= file_attributes
    file_attributes.each do |file_path| 
      article_files.build(:article_id => self.id, :articlefile => file_path)
    end
  end

end
