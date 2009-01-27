# == Schema Information
# Schema version: 20181126085723
#
# Table name: videos
#
#  id           :integer(4)      not null, primary key
#  user_id      :integer(4)
#  title        :string(255)
#  description  :text
#  state        :string(255)
#  file_path    :string(255)
#  encoded_file :string(255)
#  thumbnail    :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  tags         :string(255)
#

#require 'heywatch'
#require 'ftools'

class Video < ActiveRecord::Base
  
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :video_file_name]
  has_attached_file :video,
                                    :url =>    "/uploaded_files/video/:id/:style/:basename.:extension",
                                    :path => ":rails_root/public/uploaded_files/video/:id/:style/:basename.:extension"
  validates_attachment_presence :video
  validates_attachment_content_type :video, :content_type => ['video/quicktime','video/x-flash-video','video/mpeg','video/mp4']
  validates_attachment_size(:video, :less_than => 100.megabytes)
  #file_column :file_path
 # validates_presence_of :file_path
  def media_type
    video
  end

  def codec
    "-ar 22050 -ab 32 -f flv -y"
  end
  
end
