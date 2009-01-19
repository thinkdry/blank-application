# == Schema Information
# Schema version: 20181126085723
#
# Table name: audios
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  title       :string(255)
#  description :text
#  state       :string(255)
#  file_path   :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  tags        :string(255)
#

class Audio < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :file_path]
  
  file_column :file_path
  
  validates_presence_of :file_path
  validates_file_format_of :file_path, :in => ["mp3", "wav"]
  
end
