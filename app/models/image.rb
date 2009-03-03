# == Schema Information
# Schema version: 20181126085723
#
# Table name: images
#
#  id                 :integer(4)      not null, primary key
#  user_id            :integer(4)
#  title              :string(255)
#  description        :text
#  state              :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer(4)
#  image_updated_at   :datetime
#  created_at         :datetime
#  updated_at         :datetime
#  tags               :string(255)
#

class Image < ActiveRecord::Base
  acts_as_item
  acts_as_xapian :texts => [:title, :description, :tags, :image_file_name, :image_content_type],
                 :values => [[:created_at, 0, "created_at", :number], [:title, 1, "title", :string], [:comment_size, 2, "comment_size", :number], [:rate_size, 3, "rate_size", :number]]
               
  has_attached_file :image,
    :url =>    "/uploaded_files/image/:id/:style/:basename.:extension",
    :path => ":rails_root/public/uploaded_files/image/:id/:style/:basename.:extension",
    :styles => { :medium => "300x300>",
    :thumb => "48x48>" }
  validates_attachment_presence :image
  validates_attachment_content_type :image, :content_type => ['image/jpeg','image/jpg', 'image/png', 'image/gif','image/bmp']
  validates_attachment_size(:image, :less_than => 100.megabytes)
  #file_column :file_path, :magick => { :versions => { :thumb => "100x100", :web => "500x500" } }
  # validates_presence_of :file_path
  #  validates_file_format_of :file_path, :in => ["png", "gif", "jpg"]

  def media_type
    image
  end

  def comment_size
    self.comments.size
  end

  def rate_size
    self.rating.to_i
  end
 
end
