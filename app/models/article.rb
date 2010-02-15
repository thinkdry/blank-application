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
#  viewed_number   :integer(4)      default(0)
#  rates_average   :integer(4)      default(0)
#  comments_number :integer(4)      default(0)
#

# This class is defining an item object called 'Article'.
#
# You can use it to publish a text content on wich you can apply CSS style through FCKeditor functionality.
# You can also linked files to that article.
#
# See the ActsAsItem:ModelMethods module to have further informations.
#
class Article < ActiveRecord::Base

  # Method defined in the ActsAsItem:ModelMethods:ClassMethods (see that library fro more information)
  acts_as_item

	# Audit activation of the item
	acts_as_audited :except => :viewed_number

	# Relation 1-N to the table 'article_files', managing the files linked to the article
  has_many :article_files, :dependent => :delete_all
	# Overwriting of the ActsAsXapian specification define in ActsAsItem,
	# in order to include the 'body' field inside the Xapian index
	acts_as_xapian :texts => [:title, :description, :keywords_list, :body],:terms => [[:title,'S',"title"],[:body,'B',"body"]]

  # Validation of the presence of the 'body' field (for the update only)
  validates_presence_of :body, :on => :update

  # Files association to an Article using PaperClip plugin
  #
  # file_attributes are the associated files using paperclip attachment
  def new_file_attributes= file_attributes
    file_attributes.each do |file_path|
      article_files.build(:article_id => self.id, :articlefile => file_path)
    end
  end
  

end

