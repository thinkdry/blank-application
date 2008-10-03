class ArticFilesController < ApplicationController
  acts_as_ajax_validation
  acts_as_item
  
  # ROLES DESCRIPTION
  # New - Create:   Any User
  #                 WS assignation: Writer, Moderator or Creator of WS
  # Show:           Admin, Author or Member of one assigned WS
  # Edit - Update:  Admin, Author, Creator or Moderator of WS
  # Remove:         Admin, Author
end